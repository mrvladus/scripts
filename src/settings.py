from gi.repository import Adw, Gtk
from data import data


class CredentialsGroup(Adw.PreferencesGroup):
	def __init__(self):
		super().__init__(title="Credentials")
		# Email
		self.email = Adw.EntryRow(title="Email")
		self.add(self.email)
		# Name
		self.name = Adw.EntryRow(title="Name")
		self.add(self.name)


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
		self.props.transient_for = data["main_window"]
		self.credentials_page = Adw.PreferencesPage()
		self.credentials_page.add(CredentialsGroup())
		self.credentials_page.add(AutorizationGroup())
		self.add(self.credentials_page)