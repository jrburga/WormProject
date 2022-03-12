import os
import subprocess
import argparse
import shutil
import zipfile

def get_commit_id():
	process = subprocess.Popen(['git', 'rev-parse', '--short=7', 'HEAD'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	stdoutput, stderroutput = process.communicate()
	if stderroutput:
		print("ERROR")
		print(stderroutput)
	else:
		commit_id = stdoutput.decode("utf-8").strip()
		return commit_id
	return None

def export_html5(id):
	worm_dir = "worm-html5-%s" % id if id else "worm-html5-v0"

	project_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')

	exports_dir = os.path.join(project_path, 'Exports')
	export_path = os.path.join(exports_dir, worm_dir)
	export_file = os.path.join(export_path, 'worm.html')

	# delete the existing export
	if os.path.exists(export_path):
		shutil.rmtree(export_path)

	if not os.path.isdir(export_path):
		os.mkdir(export_path)
	os.system("godot --export \"HTML5\" %s" %  export_file)

	# rename worm.html to index.html
	if os.path.exists(export_path):
		rename_file = os.path.join(export_path, "index.html")
		os.rename(export_file, rename_file)
		print("making archive")

		with open(os.path.join(export_path, "README"), 'w') as readme:
			readme


		zip_file = worm_dir + ".zip"
		shutil.make_archive(worm_dir, 'zip', export_path)
		final_path = os.path.join(exports_dir, zip_file)
		os.replace(zip_file, final_path)
		# delete the folder to keep things clean :)
		if os.path.exists(export_path):
			shutil.rmtree(export_path)

		return export_path, zip_file
	return None

def butler_push(file, channel, id):
	if channel == 'html5':
		id = id if id else "0.0.0"
		os.system("butler push Exports/%s zekthesnek/worm:html5 --userversion %s" % (file, id))


	# # os.rename("../")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='export worm project helper')
	parser.add_argument('target', type=str)
	parser.add_argument('-p', '--push', action='store_const', const=True)

	args = parser.parse_args()
	if args.target.lower() == 'html5':
		print('exporting html5')
		commit_id = get_commit_id()
		path, file = export_html5(commit_id)
		if args.push:
			butler_push(file, 'html5', commit_id)