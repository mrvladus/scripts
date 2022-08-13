import gi, os
gi.require_version("Adw", "1")
from gi.repository import Adw, Gtk
# Modules
from data import data, settings


class ReposList(Gtk.Box):
	def __init__(self):
		super().__init__(orientation="vertical")
		data["repos_list"] = self
		# Carousel
		self.carousel = Adw.Carousel()
		data["carousel"] = self.carousel
		self.append(self.carousel)
		# Status page
		self.status = Adw.StatusPage(
				icon_name="system-search-symbolic",
				title="No repositories found",
				description='Add new one with "+"',
				hexpand=True,
				vexpand=True
				)
		# Bottom page indicator
		self.indicators = Adw.CarouselIndicatorLines(carousel=self.carousel)
		self.append(self.indicators)
		self.init_repos()

	def init_repos(self):
		# Read repos file and add page for each repo
		with open(data["repo_file"], "r") as f:
			for path in f:
				self.carousel.append(RepoPage(path))
		self.update_status()

	def update_status(self):
		# Show status page if there is no repos
		if self.carousel.get_n_pages() == 0 and self.status.get_parent() != self.carousel:
			self.carousel.append(self.status)
		# Remove it othewise
		elif self.status.get_parent() == self.carousel:
			self.carousel.remove(self.status)


class RepoPage(Adw.PreferencesGroup):
	def __init__(self, path: str):
		super().__init__()
		self.props.vexpand = True
		self.props.margin_top = 20
		self.props.margin_bottom = 20
		self.props.margin_start = 20
		self.props.margin_end = 20
		self.props.title = os.path.basename(path.strip())
		self.props.description = path.strip()
		self.props.hexpand = True
		# Delete button
		self.delete_btn = Gtk.Button(
			icon_name="edit-delete-symbolic",
			tooltip_text="Delete repository from list",
			valign="center"
			)
		self.delete_btn.connect("clicked", self.delete_clicked)
		self.set_header_suffix(self.delete_btn)
		# Commit message
		self.msg = Adw.EntryRow(title="Commit message")
		self.msg.connect("changed", self.message_changed)
		self.add(self.msg)
		# Buttons
		self.buttons = Gtk.Box(
			margin_top=20,
			halign="center",
			spacing=20
			)
		self.add(self.buttons)
		# Commit button
		self.commit_btn = Gtk.Button(label="Commit", sensitive=False)
		self.commit_btn.connect("clicked", self.commit_clicked)
		self.buttons.append(self.commit_btn)
		# Push button
		self.push_btn = Gtk.Button(label="Push", sensitive=False)
		self.push_btn.connect("clicked", self.push_clicked)
		self.buttons.append(self.push_btn)

	def message_changed(self, widget):
		if self.msg.props.text != '':
			self.commit_btn.props.sensitive = True
		else:
			self.commit_btn.props.sensitive = False

	def commit_clicked(self, button):
		if settings['email'] != '' and settings['name'] != '':
			os.system(f"cd {self.props.description} && git add -A && git commit -m '{self.msg.props.text}' --author='{settings['name']} <{settings['email']}>'")
			self.push_btn.props.sensitive = True

	def push_clicked(self, button):
		pass

	def delete_clicked(self, button):
		# Remove line from file
		with open(data["repo_file"], "r") as f:
			lines = f.readlines()
		with open(data["repo_file"], "w") as f:
			for line in lines:
				if self.props.description not in line:
					f.write(line)
		# Remove page
		data["carousel"].remove(self)
		data["repos_list"].update_status()