from argparse import ArgumentParser
import subprocess
import shlex
import time

# get dataset
def get_dataset_name(dataset, id):
    cmd = "zfs list -r -t snapshot -o name " + dataset + " | sed 1d"
    args = shlex.split(cmd)
    result = subprocess.check_output(args)
    result = result.split("\n")
    result.reverse()
    return result[id-1]

# create
def create(dataset, rot_cnt):
    print("[snapshot] " + dataset + "@" + time.strftime("%Y-%m-%d_%H:%M:%S", time.localtime()))
    cmd = "zfs snapshot " + dataset + "@" + time.strftime("%Y-%m-%d_%H:%M:%S", time.localtime())
    args = shlex.split(cmd)
    subprocess.check_call(args)

    # check snapshot counts
    cmd = "zfs list -r -t snapshot -o name " + dataset
    args = shlex.split(cmd)
    result = subprocess.check_output(args)
    result = result.split("\n")
    result.pop() # the last element is null str
    result.reverse()
    result.pop()

    if rot_cnt == None:
        rot_cnt = 20
    if len(result) > int(rot_cnt):
        print("- reach rotation count")
        for i in range(int(rot_cnt), len(result)):
            print("[delete] " + result[i])
            cmd = "zfs destroy " + result[i]
            args = shlex.split(cmd)
            subprocess.check_call(args)

# list
def list(dataset):
    # list all the snapshot
    # check_output: Run command with arguments and return its output as a byte string.
    if dataset == None:
        cmd = "zfs list -r -t snapshot -o name" # remove first line (Name)
    else:
        cmd = "zfs list -r -t snapshot -o name " + dataset
    args = shlex.split(cmd)
    result = subprocess.check_output(args)
    result = result.split("\n")
    result.reverse()
    result.pop()
    print("ID".ljust(10) + "Dataset".ljust(20) + "Time".ljust(20))
    dataset_list = {}
    for line in result:
        if line != "":
            line = line.split("@")
            if line[0] not in dataset_list:
                dataset_list[line[0]] = 1
            else:
                dataset_list[line[0]] += 1
            print(str(dataset_list[line[0]]).ljust(10) + line[0].ljust(20) + line[1].ljust(20))

# delete
def delete(dataset, id=None):
    # get all the snapshot
    cmd = "zfs list -r -t snapshot -o name " + dataset + " | sed 1d"
    args = shlex.split(cmd)
    result = subprocess.check_output(args)

    if id == None: # delete all the snapshots of this dataset
        for snapshot in result.split("\n"):
            cmd = "zfs destroy " + snapshot
            args = shlex.split(cmd)
            subprocess.check_call(args)
    else:
        snapshot = result.split("\n").reverse()[int(id)-1]
        cmd = "zfs destroy " + snapshot
        args = shlex.split(cmd)
        subprocess.check_call(args)

# export
def export(dataset, id=1):
    # export snapshot to file
    dataset_name = get_dataset_name(dataset, id)
    cmd = "zfs send -R" + dataset_name + " > " + "~/ftp_backup/export/" + dataset_name.replace("/", "_")
    dataset_name = dataset_name.replace("/", "_")
    args = shlex.split(cmd)
    subprocess.check_call(args)

    # compress
    cmd = "xz -z ~/ftp_backup/export/" + dataset_name
    args = shlex.split(cmd)
    subprocess.check_call(args)

    # encrypt
    cmd = "openssl aes256 -in ~/ftp_backup/export/" + dataset_name + ".xz + -out ~/ftp_backup/export/" + dataset_name + ".xz.enc"
    args = shlex.split(cmd)
    subprocess.check_call(args)

    # remove reduntant .xz file
    cmd = "rm ~/ftp_backup/export/" + dataset_name + ".xz"
    args = shlex.split(cmd)
    subprocess.check_call(args)

def _import(dataset, filename):
    filename = "~/ftp_backup/export/" + filename
    # decrypt
    cmd = "openssl enc -aes256 -d -in " + filename + " -out " + filename[:-4]
    args = shlex.split(cmd)
    subprocess.check_call(args)

    # uncompress
    cmd = "xz -d " + filename[:-4]
    args = shlex.split(cmd)
    subprocess.check_call(args)

    # clean the previous snapshot
    delete(dataset)

    # import
    cmd = "sudo zfs receive -F " + filename.split("@")[0] + " < " + filename[:-7]
    args = shlex.split(cmd)
    subprocess.check_call(args)

# test subprocess
def test():
    # result = subprocess.check_output(args)
    result = subprocess.check_output(["cat", "zfs_list.txt"])
    result = result.split("\n")
    if len(result) > 5:
        for i in range(0, 5):
            print("delete" + result[i])

parser = ArgumentParser(usage="./zbackup [[--list | --delete | --export] target-dataset [ID] | [--import] target-dataset filename | target-dataset [rotation count]]")

# zbackup [[--list | --delete | --export] target-dataset [ID] | [-- import] target-dataset filename | target dataset [rotation count]]

group = parser.add_mutually_exclusive_group()
group.add_argument("-l", "--list", help="List the snapshot created by zbackup (default=all)", action="store_true")
group.add_argument("-d", "--delete", help="Delete the specified snapshots created by zbackup (default=all)", action="store_true")
group.add_argument("-e", "--export", help="Export specified snapshot, which is 'dataset/to/backup@2018-10-12.xz.enc'", action="store_true")
group.add_argument("-i", "--_import", help="Load the snapshot to the dataset", action="store_true")

parser.add_argument("dataset", help="target-dataset", nargs="?")
parser.add_argument("id_cnt", help="ID/import-filename/rotation count", nargs="?")

args = parser.parse_args()

if args.list == True:
    list(args.dataset)
elif args.delete == True:
    delete(args.dataset, args.id_cnt)
elif args.export == True:
    export(args.dataset, args.id_cnt)
elif args._import == True:
    _import(args.dataset, args.id_cnt)
else: # create
    create(args.dataset, args.id_cnt)
