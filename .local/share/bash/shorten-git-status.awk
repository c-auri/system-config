#!/usr/bin/awk -f

# condenses git status output for the prompt in `.bashrc`

BEGIN {
    FS="[ (]"
}
/On branch/ { branch=$3 }
/interacti/ { rebase=1 }
/Last comm/ { done=$5 }
/Next comm/ { todo=$6 }
/HEAD deta/ { detached=1 }
END {
    if (branch) {
        print branch
    } else if (rebase) {
        printf "REBASE %s/%s",done,done+todo
    } else if (detached) {
        print "DETACHED HEAD"
    }
}
