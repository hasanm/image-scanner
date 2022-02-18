int main (string[] args)
{
	Gtk.init(ref args);
	var model = new MyModel();	
	var window = new MainWindow(model);




	window.set_border_width(10);
	window.set_default_size(1024, 768);
	window.show_all();


	Gtk.main();
	return 0;	
}

