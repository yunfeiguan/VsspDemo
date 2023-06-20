import os
import shutil 
import hashlib
import argparse


def get_file_md5(fname):
    m = hashlib.md5()   #create md5 obj
    with open(fname,'rb') as fobj:
        while True:
            data = fobj.read(131072)
            if not data:
                break
            m.update(data)  #update md5

    return m.hexdigest()    #return md5

def update_packages(src_path, dest_path):
    print 'starting update packges ... '
    # list all files in the parent directory
    dirs = [f for f in os.listdir(src_path)]

    # print the list of files
    print 'packages in the src directory:', dirs
    print '\n'

    #import pdb;pdb.set_trace()
    # copy this packages to dest path
    for package in dirs:
        src_pack_dir = src_path + '/' + package + '/'
	dest_pack_dir = dest_path + '/' + package + '/'

	if os.path.exists(src_pack_dir):
	    src_package = os.listdir(src_pack_dir)
	    if src_package.count('.gitkeep'):
		src_package.remove('.gitkeep')

	    dest_package = ''	
	    if not os.path.exists(dest_pack_dir):
		os.mkdir(dest_pack_dir)
            else:    
	        dest_package=os.listdir(dest_pack_dir)
		# delete dest dir packages
                for pkg in os.listdir(dest_pack_dir):
                    os.unlink(os.path.join(dest_pack_dir,pkg))	
		
	    print "updating ............................. repo:", package
	    print "new:", src_package
	    print "old:", dest_package


    	    for pkg in src_package:
        	suffix = "whl"
		if pkg.endswith(suffix):
		    #print "pkg is:", pkg 
		    src_pkg = src_pack_dir + pkg
		    try:
			#import pdb;pdb.set_trace()
			shutil.copy(src_pkg, dest_pack_dir)
		    except IOError as exc:
                	print "failed to copy package:", src_pkg
			
		print "\n"
		
		
def compare_packages(src_path, dest_path):
    print 'starting update packges ... '
    # list all files in the parent directory
    dirs = [f for f in os.listdir(src_path)]

    # print the list of files
    print 'packages in the src directory:', dirs
    print '\n'

    #import pdb;pdb.set_trace()
    # copy this packages to dest path
    for package in dirs:
	# /mnt/usr/ivan/pack_check/xd-anna/
        src_pack_dir = src_path + '/' + package + '/'
        #/mnt/usr/ivan/pack_bak/xd-anna/
        dest_pack_dir = dest_path + '/' + package + '/'

        if os.path.exists(src_pack_dir):
	    # skip this repo if dst pack is not exist
            if not os.path.exists(dest_pack_dir):
		continue
            	
	    src_package = os.listdir(src_pack_dir)
            if src_package.count('.gitkeep'):
                src_package.remove('.gitkeep')
 	    
	    dest_package = os.listdir(dest_pack_dir)
	    if src_package.count('.gitkeep'):
                src_package.remove('.gitkeep')	

            for src_pkg in src_package:
	        src_pkg_name = src_pkg.split('-')[0]
	        #print "pkg_name:", src_pkg_name

		for dst_pkg in dest_package:
		    if dst_pkg.startswith(src_pkg_name):
		        src_pkg_md5 = get_file_md5(os.path.join(src_pack_dir, src_pkg))
			dst_pkg_md5 = get_file_md5(os.path.join(dest_pack_dir, dst_pkg))

			if src_pkg_md5 == dst_pkg_md5:
			    print ("{0:15}: src == dst = :{1} is ok!".format(src_pkg_name,src_pkg_md5))
			else:
			    print ("{0:15}: src = {1}, dst = {2} is not ok!".format(src_pkg_name, src_pkg_md5, dst_pkg_md5))
	    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='A simple command-line argument parser example')
    parser.add_argument('command', help='input command update/compare', type=str)
    parser.add_argument('--src_path', help='input src_path', required=True)
    parser.add_argument('--dest_path', help='output dest_path', required=True)
    parser.add_argument('--verbose', help='output dest_path', action='store_true')

    args = parser.parse_args()

    if args.verbose:
        print "Command:", args.command
        print 'Src path:', args.src_path
        print 'Dest file path:', args.dest_path 

    # path check
    if not os.path.exists(args.src_path):
	print "{0} is not exists!".format(args.src_path)
	os._exit(-1)

    if not os.path.exists(args.dest_path):
        print "{0} is not exists!".format(args.dest_path)
        os._exit(-1)
    
    if args.command == 'update':
        update_packages(args.src_path, args.dest_path)
    elif args.command == 'compare':
	compare_packages(args.src_path, args.dest_path);
    else:
	print "command is not correct!"
	os._exit(-1)
