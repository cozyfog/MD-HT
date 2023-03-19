module main

import os

__global (
	filename	string
	htmltag		bool
	codeblock	bool
)

fn read_file() []string {
	assert os.args.len > 1
	filename = os.args[1]
	
	mut file := os.read_file(filename) or { panic('unable to read file $filename') }

	return file.split('\n')
}

fn check_line(input_line string) string {
	mut line := input_line
	mut split := line.split(' ')

	if split[0].len > 2 {
		if split[0][0] == '<'.str {
			if split[0][1] != '/'.str {
				htmltag = true
				return line
			} else {
				htmltag = false
				return line
			}
		}
	}

	if htmltag {
		return line
	}

	if split[0] == "'''" {
		codeblock = !codeblock
		if codeblock {
			return '<div class="codeblock">'
		}
		return '</div>'
	} else if codeblock {
		line_edited := line.replace(' ', '&emsp;')
		return '<p>$line_edited</p>'
	}

	for i in 0 .. split.len {
		mut split_split := split[i].replace('**', '__').split('__')
		for c in 0 .. split_split.len {
			if c != 0 && split[0] != '' {
				split_split[c] = '<strong>' + split_split[c] + '</strong>'
			}
		}
		
		split[i] = split_split.join('')

		mut split_ital := split[i].replace('*', '_').split('_')
		for c in 0 .. split_ital.len {
			if c != 0 && split[0] != '' {
				split_ital[c] = '<em>' + split_ital[c] + '</em>'
			}
		}
		
		split[i] = split_ital.join('')

		line = split.join(' ')
	}

	if split[0].replace('#', '') == '' {
		hash_len := split[0].len
		split[0] = ''
		line = '<h$hash_len>' + split.join(' ') + '</h$hash_len>'
	}

	else if split[0] == '-' {
		if split[1] == '[' && split[2] == ']' {
			split[0] = ''
			split[1] = ''
			split[2] = ''
			line = '<input type="checkbox">' + split.join(' ')
		} else if split[1].to_lower() == '[x]' {
			split[0] = ''
			split[1] = ''
			line = '<input type="checkbox" checked>' + split.join(' ')
		}
	}

	if split.len >= 2 {
		if split[0].len >= 3 && split[1].len >= 2 {
			if split[0][0] == '['.str && split[0][split[0].len - 1] == ']'.str {
				if split[1][0] == '('.str && split[1][split[1].len - 1] == ')'.str {
					line = '<a href="' + split[1].replace('(', '').replace(')', '') + '">' + split[0].replace('[', '').replace(']', '') + '</a>'
				}
				return line
			}
		}
	}


	return '<header>' + line + '</header>'
}

fn  main() {
	mut data := read_file()
	
	htmltag   = false
	codeblock = false

	for i in 0 .. data.len {
		if data[i] == '' && !htmltag {
			data[i] = '&emsp;<br>'
		} else {
			data[i] = check_line(data[i])
		}
	}

	filename += '.html'


	mut output := os.create(filename) or { panic('unable to create file $filename') }
	output.close()
	os.write_file(filename, '<!DOCTYPE html>\n' + data.join('\n')) or {
		panic('unable to write output to file $filename')
	}
	
	println('output: $filename')
}
