from argparse import ArgumentParser
import subprocess
import shlex
import time

# create
def create(dataset, rot_cnt=20):
    cmd = "zfs snapshot " + dataset + "@" + time.strftime("%Y-%m-%d_%H:%M:%S", time.localtime())
    args = shlex.split(cmd)
    print(subprocess.check_output(args))

# list
def list(dataset):
    # list all the snapshot
    # check_output: Run command with arguments and return its output as a byte string.
    if dataset == None:
        cmd = "zfs list -r -t snapshot -o name | sed 1d" # remove first line (Name)
    else:
        cmd = "zfs list -r -t snapshot -o name " + dataset + " | sed 1d"
    args = shlex.split(cmd)
    result = subprocess.check_output(args)
    print("ID".ljust(10) + "Dataset".ljust(20) + "Time".ljust(20) + "\n")
    dataset_list = {}
    for line in result.split("\n"):
        if line != "":
            line = line.split("@")
            if line[0] not in dataset_list:
                dataset_list[line[0]] = 1
            else:
                dataset_list[line[0]] += 1
            print(str(dataset_list[line[0]]).ljust(10) + line[0].ljust(20) + line[1].ljust(20))

# delete
def delete(dataset, id):
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
        snapshot = result.split("\n")[int(id)-1]
        cmd = "zfs destroy " + snapshot
        args = shlex.split(cmd)
        subprocess.check_call(args)





# test subprocess
def test():
    result = subprocess.check_output(["sed", "1d","test.txt"])
    print("ID".ljust(10) + "Dataset".ljust(20) + "Time".ljust(20))
    # print(result.split("\n"))
    dataset_list = {}
    for line in result.split("\n"):
        if line != "":
            line = line.split("@")
            if line[0] not in dataset_list:
                dataset_list[line[0]] = 1
            else:
                dataset_list[line[0]] += 1
            print(str(dataset_list[line[0]]).ljust(10) + line[0].ljust(20) + line[1].ljust(20))
    # print(result)

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

test()

if args.list == True:
    print("list!")
elif args.delete == True:
    print("delete!")
elif args.export == True:
    print("export!")
elif args._import == True:
    print("import!")
else: # create
    create(args.dataset)

print("args.dataset = " + args.dataset)
if args.id_cnt != None:
    print("args.id_cnt = " + args.id_cnt)
# print("delete arg = " + args.dataset)
# print("export arg = " + args.dataset)
