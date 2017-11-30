// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
/*
  test xtd connection interface with ceph
*/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>

#ifndef __USE_FILE_OFFSET64
#define __USE_FILE_OFFSET64 1
#endif

#include <cephfs/libcephfs.h>
#include <limits.h>
#include <unistd.h>
#include <sys/types.h>

#include <rados/librados.h>
#include <vector>
//#include "librados/RadosClient.h"

using namespace std;
typedef void* rados_t;
typedef unsigned char uuid_t[16];

typedef struct obj_id{
  ino_t inode;
  uuid_t uuid;
} obj_id_t;

typedef struct mattr {
  obj_id_t parentid;
  obj_id_t fid;
  mode_t    mode;
  nlink_t   nlink;
  uid_t     uid;
  gid_t     gid;
  off_t     size;
  time_t    atime;
  time_t    mtime;
  time_t    ctime;
  char reserve[8];
} mattr_t; 

typedef enum {
  op_create = 0,
  op_unlink,
  op_rename,
  op_mkdir,
  op_rmdir,
  op_setattr,
  op_link,
  op_none,
  op_done
} op_type_t;

typedef struct journal_entry {
  uint64_t seq;
  uint64_t len;
  op_type_t op;
  char *name;
  char *name2; /* reserved for rename */
  mattr_t *attr;
  mattr_t *attr2;
  mattr_t *pattr;
  mattr_t *pattr2; /* reserved for rename */
  void *xattr; /* nv list */
} journal_entry_t;

int rados_mon_command(rados_t cluster, const char **cmd,
		size_t cmdlen,
		const char *inbuf, size_t inbuflen,
		char **outbuf, size_t *outbuflen,
		char **outs, size_t *outslen)
{
	int ret = 0;
	//librados::RadosClient *client = (librados::RadosClient *)client;
/*	bufferlist inbl;
	bufferlist outbl;
	string outstring;
	vector<string> cmdvec;

	for (size_t i = 0; i < cmdlen; i++) {
		tracepoint(librados, rados_mon_command_cmd, cmd[i]);
		cmdvec.push_back(cmd[i]);
	}

	inbl.append(inbuf, inbuflen);
	int ret = client->mon_command(cmdvec, inbl, &outbl, &outstring);

	do_out_buffer(outbl, outbuf, outbuflen);
	do_out_buffer(outstring, outs, outslen);*/
	return ret;
}

int main(int argc, char **argv)
{
  struct ceph_mount_info *cmount = NULL;
  struct journal_entry *pjentry = NULL;
  Inode *root = NULL;
  void *raw_pjentry = NULL;
  void *root_ent = NULL;
  int len = 0;
  int total = 0;
  int complete = 0;
  
  int ret = -1;
  
  if (argc < 2) {
      printf("Specify the mds host name will consume please!\n");
      return -1;
  } else {
      printf("will consume mds: %s\n", argv[1]);
  }

  printf("111111\n");
  ret = ceph_create(&cmount, NULL);
  if (ret) {
    printf("ceph_create fail\n");
    return -1;
  }
  ret = ceph_conf_read_file(cmount, "/etc/ceph/xtao.conf");
  printf("2222222\n");
  //ret = ceph_init(cmount);
  // ceph mount make sure we get the inode and the corresponding layout
  ret = ceph_mount(cmount, NULL);
  if (ret) {
    printf("ceph_init/mount fail\n");
    return -1;
  }
  printf("333333\n");
  // after ceph_init, the client has already got the mdsmap
  ret = ceph_mh_open_journal(cmount, argv[1]);
  if (ret) {
    printf("ceph open journal fail\n");
    return -1;
  }
  printf("444444\n");

  root_ent = malloc(sizeof(struct mattr));
  ret = ceph_mh_get_root(cmount, root_ent, sizeof(struct mattr));
  if (ret) {
    printf("ceph get root fail");
    return -1;
  }
  
  printf("found root fid %0x%llx\n", ((struct mattr*)root_ent)->fid.inode);

  printf("*****************************\n");
  len = sizeof(struct journal_entry);
  int i = 0;
  while (!complete) {
    raw_pjentry = malloc(len);
    ret = ceph_mh_hold_journal_entry(cmount, raw_pjentry, len);
    if (ret) {
      free(raw_pjentry);
      raw_pjentry = NULL;
      break;
    }
    pjentry = (struct journal_entry *) raw_pjentry;

    printf("found journal entry seq %d, length %d, op %d, name %s,parentid 0x%llx  fid 0x%llx \n",
	   pjentry->seq, pjentry->len, pjentry->op, pjentry->name,
	   pjentry->attr->parentid.inode,
	   pjentry->attr->fid.inode);
    i++;
    // release the journal
    printf("will release jentry seq %d\n", pjentry->seq);
    ret = ceph_mh_release_journal_entry(cmount, pjentry->seq);
    if (ret) {
      free(raw_pjentry);
      raw_pjentry = NULL;
      
      complete = 1;
      printf("release jentry failed");
      break;
    }   

    free(raw_pjentry);
    raw_pjentry = NULL;

  }

  if (complete) {
    printf("ceph hold jentry complete\n");
    delete pjentry;
    pjentry = NULL;
  }

  return 0;
}
