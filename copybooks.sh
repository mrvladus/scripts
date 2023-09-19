#!/usr/bin/bash

select_book(){
	from=$(zenity --title="Выберите папку c книгой" --file-selection --directory)
	if [[ ! $from ]]
	then
		zenity --error --text="Не выбрана папка!" --no-wrap
		return
	fi
	to=$(zenity --title="Куда скопировать" --file-selection --directory)
	if [[ ! $to ]]
	then
		zenity --error --text="Не выбрана папка!" --no-wrap
		return
	fi
	copy_book
}

copy_book(){
	cd $from
	find -type f -print0 | sort -z | cpio -0 -pvd $to/$(basename $from)/
	zenity --info --text="Готово!"
}

select_book