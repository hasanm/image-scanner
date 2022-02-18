all:
	valac --pkg gtk+-3.0 --pkg cairo  --pkg glib-2.0 --color=never Main.vala MainWindow.vala
