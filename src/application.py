import gi, os, json
gi.require_version("Adw", "1")
from gi.repository import Adw, Gtk, GLib
# Data
from data import data, default_settings
# Modules
from headerbar import HeaderBar
from repos_list import ReposList


class MainWindowContent(Gtk.Box):
	def __init__(self):
		super().__init__(orientation=Gtk.Orientation.VERTICAL)
		self.append(HeaderBar())
		self.append(Adw.ToastOverlay(child=ReposList()))


class Application(Adw.Application):
	def __init__(self):
		super().__init__(application_id="com.github.mrvladus.Pusher")
		data["app"] = self

	def init_repos_file(self):
		# Create repos file if not exists
		data_dir = GLib.get_user_cache_dir() + "/pusher"
		data["repo_file"] = data_dir + "/pusher.repos"
		os.system(f"mkdir -p {data_dir} && touch {data['repo_file']}")

	def init_settings_file(self):
		# Create settings file if not exists
		data_dir = GLib.get_user_cache_dir() + "/pusher"
		data["settings_file"] = data_dir + "/settings.json"
		os.system(f"touch {data['settings_file']}")
	
	def init_settings(self):
		# Initialize settings file
		# Load file
		with open(data["settings_file"], "r") as f:
			content = f.read()
		# Create default settings if file is empty
		if content == '':
			with open(data["settings_file"], "w") as f:
				json.dump(default_settings, f)

	def do_activate(self):
		self.init_repos_file()
		self.init_settings_file()
		self.init_settings()
		window = Adw.ApplicationWindow(
			application=self,
			title="Pusher",
			resizable=False,
			content=MainWindowContent()
			)
		data["main_window"] = window
		window.show()


Application().run()
