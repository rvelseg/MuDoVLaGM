# http://realiseyourdreams.wordpress.com/latex-scripts/

#Script to remove all LaTex-Comments from .tex-files
import os,subprocess

#browse the directory
for dirname, dirnames, filenames in os.walk('.'):
for filename in filenames:
#Check every file for:
filepath    = os.path.join(dirname, filename)
#tex file
if    filename.endswith('.tex'):
print "open file: "+filepath
#rename the file
tmpfilepath    = filepath+"~"
process = subprocess.Popen(["mv",filepath,tmpfilepath])
process.wait()
newfile        = open(filepath,"w")
oldfile        = open(tmpfilepath,'r')
for line in oldfile.readlines():
#Search for a comment
pos    = line.find('%')
if    pos != -1:
#Write the line back without the comment
#Sometimes the percent-sign is important. Therefore just erase the comment
newfile.write(line[0:pos+1]+"\n")
else:
#Write the line completely
newfile.write(line)
newfile.close()
oldfile.close()
process = subprocess.Popen(["rm",tmpfilepath])
process.wait()

# no attemp is made to preserve \% or comments inside verbose envirinments
