#------------------------#
#     UTILS FUNCTIONS    #
#------------------------#
import os

# Clear console
def clear():
	os.system('clear')

# Pause script for debug purposes
def pause():
	pause = input('Continue? (Y/n)') or 'y'
	if pause == 'y':
		return
	else:
		exit()

# Find string in file and replace it with new string
def find_and_replace(line: str, new_line: str, file_path: str):
	os.system(f"sed -i -e 's/{line}/{new_line}/g' {file_path}")

# Execute shell command
def cmd(command: str = ''):
	os.system(command)

# Execute command in chroot
def chroot_cmd(command: str = ''):
	if os.path.exists('/bin/arch-chroot'):
		os.system(f'arch-chroot /mnt /bin/bash -c "{command}"')
	else:
		os.system(f'chroot /mnt /bin/bash -c "{command}"')

# Create new file and write text into it
def create_file(text: str, path: str):
	with open(path, 'w') as f:
		f.write(text)

# Append text to the end of the file
def append_to_file(text: str, path: str):
	with open(path, 'a') as f:
		f.write(text)