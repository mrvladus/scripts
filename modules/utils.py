import os

def find_and_replace(line: str, new_line: str, file_path: str):
	os.system(f"sed -i -e 's/{line}/{new_line}/g' {file_path}")