import json
from gi.repository import Adw, Gtk
from data import data

def get_settings():
	with open(data["settings_file"], "r") as f:
		return json.load(f)

def get_setting(setting: str):
	settings = get_settings()
	return settings[setting]

def set_setting(setting: str, value: str):
	new_settings = get_settings()
	# Set new value
	new_settings[setting] = value
	# Write to file
	with open(data["settings_file"], "w") as f:
		json.dump(new_settings, f)


class CredentialsGroup(Adw.PreferencesGroup):
	def __init__(self):
		super().__init__(title="Credentials")
		# Email
		self.email = Adw.EntryRow(title="Email", text=get_setting("email"))
		self.email.connect("changed", self.email_changed)
		self.add(self.email)
		# Name
		self.name = Adw.EntryRow(title="Name", text=get_setting("name"))
		self.name.connect("changed", self.name_changed)
		self.add(self.name)

	def email_changed(self, widget):
		set_setting("email", self.email.props.text)
	
	def name_changed(self, widget):
		set_setting("name", self.name.props.text)
	

class AutorizationGroup(Adw.PreferencesGroup):
	def __init__(self):
		super().__init__(title="Autorization")
		# GitHub
		self.github_token = Adw.PasswordEntryRow(title="GitHub Token")
		self.add(self.github_token)
		# GitHub link
		self.github_token_link = Gtk.LinkButton(
			label="Get GitHub Token",
			uri="https://github.com"
			)
		self.add(self.github_token_link)


class SettingsWindow(Adw.PreferencesWindow):
	def __init__(self):
		super().__init__()
		self.props.destroy_with_parent = True
		self.props.hide_on_close = True
		self.props.transient_for = data["main_window"]
		self.credentials_page = Adw.PreferencesPage()
		self.credentials_page.add(CredentialsGroup())
		self.credentials_page.add(AutorizationGroup())
		self.add(self.credentials_page)
