#!/Users/lucasch/Library/Enthought/Canopy_64bit/User/bin/python

from sys import argv

template = "template.html"
snippet_filename = argv[1]
output_filename= argv[2]
pdf_title = argv[3]
pdf_location = argv[4]



def read_template(template):
	with open(template) as f:
		lines = f.readlines()
	return lines


def parse_title(pdf_title):
	words = pdf_title.split("_")
	new_title = ""
	for word in words:
		new_title +=word+" "
	return new_title

def gen_pdf_object(pdf_location):
	pdf_object = "<object data=\""+pdf_location+"\" type=\"application/pdf\" width=\"100%\" height=\"90%\">\n"
	pdf_object += "</object>\n"
	pdf_object += "<p>Link <a href=\""+pdf_location+"\">to the PDF!</a></p>\n"
	return pdf_object

def read_snippet(snippet):
	with open(snippet) as f:
		lines = f.readlines()
	return lines

def generate_page(snippet_filename,pdf_title,pdf_location,output_filename):
	pdf_title = parse_title(pdf_title)
	template_contents = read_template(template)
	f = open(output_filename,'w')

	for line in template_contents:
		if line == "<!-- Template Titlebar -->\n":
			f.write(pdf_title)
		elif line == "<!-- Template Page Title-->\n":
			title_string = "<a class=\"navbar-brand\" href=\"#\">"+pdf_title+"</a>\n"
			f.write(title_string)
		elif line == "<!-- Template Paper Title -->\n":
			title_string = "<h3>"+pdf_title+"</h3>\n"
			f.write(title_string)
			pdf_obj = gen_pdf_object(pdf_location)
			f.write(pdf_obj)
		elif line == "<!-- Template Summary-->\n":
			summary = read_snippet(snippet_filename)
			for line in summary:
				f.write(line)
			f.write("\n")
		else:
			f.write(line)
	f.close()


	


generate_page(snippet_filename,pdf_title,pdf_location,output_filename)

