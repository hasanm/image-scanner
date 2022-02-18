class MyModel
{
	private string _image_name_1 = "IMG_1.JPG";
	private string _image_name_2 = "IMG_2.JPG";
	private string _image_name_3 = "IMG_3.JPG";

	public string image_name_1 {
		get { return _image_name_1; }
		set { _image_name_1 = value; }
	}

	public string image_name_2 {
		get { return _image_name_2; }
		set { _image_name_2 = value; }
	}


	public string image_name_3 {
		get { return _image_name_3; }
		set { _image_name_3 = value; }
	}
}


class MainWindow : Gtk.Window
{
	private Gtk.Button _button;
	private int click_counter = 0;

	private Gtk.Box _main_panel; 
	private Gtk.Box _top_panel;
	private Gtk.Box _content_panel;

	private Gtk.Frame _frame_left;
	private Gtk.Frame _frame_right;


	private Gtk.Image _image_left;
	private Gtk.Image _image_right;

	private Gdk.Pixbuf _pixbuf_source;
	private Gdk.Pixbuf _pixbuf_left;
	private Gdk.Pixbuf _pixbuf_right;

	private Gtk.EventBox _event_box;
	private Gtk.Overlay _overlay;
	private Gtk.DrawingArea _drawing_area; 

	private MyModel _model;

	private bool tracking = false;

	private double starting_x = 0;
	private double starting_y = 0;
	private double ending_x = 1;
	private double ending_y = 1;

	public void draw (Cairo.Context context) {
		context.set_source_rgba(0.0, 0.7, 0.0, 0.2);
		context.set_line_width(10);
		context.move_to(starting_x, starting_y);
		context.line_to(ending_x, ending_y);

		context.stroke();
		
	}

	public void button_pressed (double x, double y) {
		if (tracking == false) {
			starting_x = ending_x = x;
			starting_y = ending_y = y;
		}  else {
			ending_x = x;
			ending_y = y; 
		}
		_drawing_area.queue_draw();
		tracking = !tracking; 
	}

	public void button_motion (double x, double y) {
		stdout.printf("%f x %f\n", x, y);
		if (tracking ) {
			ending_x = x;
			ending_y = y;
			_drawing_area.queue_draw();
		} 
	}

	public void attach_image_to_frame (ref Gtk.Frame frame, ref Gtk.Image image) {
		if (frame.get_child() != null) {
			frame.remove(frame.get_child()); 
		}
		frame.add(image); 
	}

	public void attach_image_to_overlay (ref Gtk.Image image) {
		if (_overlay.get_child() != null) {
			_overlay.remove(_overlay.get_child()); 
		}
		_overlay.add(image); 
	} 
	

	public void copy_image(){
		_pixbuf_right = _pixbuf_left.copy();
		_image_right = new Gtk.Image.from_pixbuf(_pixbuf_right);

		attach_image_to_overlay(ref _image_right);
		_content_panel.show_all();
	}

	public void rotate_image(){
		_pixbuf_right = _pixbuf_right.rotate_simple(Gdk.PixbufRotation.CLOCKWISE);
		_image_right = new Gtk.Image.from_pixbuf(_pixbuf_right);

		attach_image_to_overlay(ref _image_right);
		_content_panel.show_all();
	}

	public void flip_image() {
		_pixbuf_right = _pixbuf_right.flip(true);
		_image_right = new Gtk.Image.from_pixbuf(_pixbuf_right);

		attach_image_to_overlay(ref _image_right);
		_content_panel.show_all();
	}


	public void cut_image() {
		int src_x = (int) (starting_x < ending_x ? starting_x : ending_x);
		int src_y = (int) (starting_y < ending_y ? starting_y : ending_y);
		int width = (int) Math.fabs(ending_x - starting_x);
		int height = (int) Math.fabs(ending_y - starting_y);

		stdout.printf("Cutting %d,%d => %d,%d\n", src_x, src_y, width, height);
		_pixbuf_right = new Gdk.Pixbuf.subpixbuf(_pixbuf_right, src_x, src_y, width, height);
		_image_right = new Gtk.Image.from_pixbuf(_pixbuf_right);

		attach_image_to_overlay(ref _image_right);
		_content_panel.show_all();
	} 	

	public void load_images (int window_x, int window_y) {
		int image_x = (window_x / 2) - 30;
		if (image_x > 800) {
			image_x = 800; 
		} 
		_pixbuf_source = new Gdk.Pixbuf.from_file(_model.image_name_1);
		if (_pixbuf_source != null) {
			stdout.printf("Pixbuf loaded %dx%d\n", _pixbuf_source.width, _pixbuf_source.height);
		}

		int ratio = _pixbuf_source.width / image_x; 
		_pixbuf_left = _pixbuf_source.scale_simple(_pixbuf_source.width/ratio,
												   _pixbuf_source.height/ratio,
												   Gdk.InterpType.HYPER);

		_image_left = new Gtk.Image.from_pixbuf(_pixbuf_left);

		attach_image_to_frame(ref _frame_left, ref _image_left);

		_content_panel.show_all();
	} 

	public MainWindow (MyModel model)
	{
		this._model = model; 
		this.title = "My Image Scanner";
		this.destroy.connect (Gtk.main_quit);

		_main_panel = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		_top_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		_content_panel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		_main_panel.pack_start(_top_panel, false, false, 0);
		_main_panel.pack_start(_content_panel, false, false, 0);


		_frame_left = new Gtk.Frame("left");
		_frame_right = new Gtk.Frame("right");

		_overlay = new Gtk.Overlay();
		_event_box = new Gtk.EventBox();
		_drawing_area = new Gtk.DrawingArea();

		_event_box.add_events(Gdk.EventMask.POINTER_MOTION_MASK);
		_event_box.add_events(Gdk.EventMask.BUTTON_PRESS_MASK);

		_drawing_area.draw.connect( (cr) => {
				draw(cr);
				return true; 
			});

		_event_box.add(_drawing_area);

		_event_box.button_press_event.connect( (event) => {
				button_pressed(event.x, event.y);
				return false; 
			} );

		_event_box.motion_notify_event.connect ( (event) =>  {
				if (tracking) { 
					button_motion(event.x, event.y);
				}
				return false; 
			}); 

		_overlay.add_overlay(_event_box); 
		_frame_right.add(_overlay); 

		// _frame_left.set_size_request(480, 480);
		// _frame_right.set_size_request(480, 480);

		_content_panel.pack_start(_frame_left, false, false, 0);
		_content_panel.pack_start(_frame_right, false, false, 0);

		
		_button = new Gtk.Button.with_label("Click me (0)");
		
		_button.clicked.connect ( () => {
				_button.label = "Clicke me (%d)".printf(++this.click_counter);
				load_images(this.get_allocated_width(), this.get_allocated_height());
			}); 

		_top_panel.pack_start(_button, false, false, 0);

		var button = new Gtk.Button.with_label("Copy");
		button.clicked.connect ( () => {
				copy_image();
			});

		_top_panel.pack_start(button, false, false, 0);


		button = new Gtk.Button.with_label("Flip");
		button.clicked.connect ( () => {
				flip_image();
			});

		_top_panel.pack_start(button, false, false, 0);


		button = new Gtk.Button.with_label("Rotate");
		button.clicked.connect ( () => {
				rotate_image();
			});

		_top_panel.pack_start(button, false, false, 0);

		button = new Gtk.Button.with_label("Cut");
		button.clicked.connect ( () => {
				cut_image();
			});
		
		_top_panel.pack_start(button, false, false, 0);

		add(_main_panel);

		this.size_allocate.connect ( (allocation) => {
				stdout.printf("Current window size : %dx%d\n", allocation.width, allocation.height);
				// load_images(allocation.width, allocation.height);
			}); 
	}	
} 


