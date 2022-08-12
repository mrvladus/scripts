import gi, os
gi.require_version("Adw", "1")
from gi.repository import Adw, Gtk, GLib
# Data
from data import data
# Modules
from headerbar import HeaderBar
from repos_list import ReposList


class MainWindowContent(Gtk.Box):
	def __init__(self):
		super().__init__(orientation=Gtk.Orientation.VERTICAL)
		self.append(HeaderBar())
		self.append(ReposList())


class Application(Adw.Application):
	def __init__(self):
		super().__init__(application_id="com.github.mrvladus.Pusher")
		data["app"] = self

	def init_repos(self):
		data_dir = GLib.get_user_cache_dir() + "/pusher"
		data["repo_file"] = data_dir + "/pusher.repos"
		os.system(f"mkdir -p {data_dir} && touch {data['repo_file']}")

	def do_activate(self):
		self.init_repos()
		window = Adw.ApplicationWindow(
			application=self,
			title="Pusher",
			resizable=False,
			content=MainWindowContent()
			)
		data["main_window"] = window
		window.show()


Application().run()
