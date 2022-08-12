from gi.repository import Gtk
# Data
from data import data
# Modules
from settings import SettingsWindow
from repos_list import RepoPage


class HeaderBar(Gtk.HeaderBar):
	def __init__(self):
		super().__init__(css_classes=['flat'])
		self.pack_start(AddRepoBtn())
		self.pack_end(SettingsBtn())		


class AddRepoBtn(Gtk.Button):
	def __init__(self):
		super().__init__()
		self.props.icon_name = "list-add-symbolic"
		self.props.tooltip_text = "Add repository"
	
	def do_clicked(self):
		# Show folder select dialog
		self.dialog = Gtk.FileChooserNative(
			title="Select repository",
			transient_for=data["main_window"],
			action=Gtk.FileChooserAction.SELECT_FOLDER,
			accept_label="Open",
    		cancel_label="Cancel"
			)
		self.dialog.connect("response", self.on_response)
		self.dialog.show()

	def on_response(self, widget, response):
		if response == Gtk.ResponseType.ACCEPT:
			# Add page for each repo
			path = self.dialog.get_file().get_path()
			with open(data["repo_file"], "r+") as f:
				if path not in f.read():
					f.write(path + "\n")
					data["carousel"].append(RepoPage(path))
			data["repos_list"].update_status()
		# Hide dialog
		self.dialog.hide()


class SettingsBtn(Gtk.Button):
	def __init__(self):
		super().__init__()
		self.props.icon_name = "emblem-system-symbolic"
		self.props.tooltip_text = "Settings"

	def do_clicked(self):
		SettingsWindow().show()