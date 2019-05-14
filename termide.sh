# outputs path of all java files that contain the argument string
# TODO: this is really slow
function jfind {
  find . -name '*.java' -exec grep -Hil $1 {} +
}

# opens all java files that contain the argument string for editting
# and seeks to the first occurance of the argument
# TODO: only works on the first of the set of tabs
function find-edit {
  emacs `jfind $1`
}

function open-class {
  c=`find . -name "$1.java"`
  if [[ -a $c ]]
    then emacs $c
    else find-edit "class $1 "
  fi
}
function open-class-completions {
  reply=($(find . -regex ".*$1.*\.java" | xargs -I {} basename {} .java))
}
compctl -K open-class-completions open-class 

# $1 : path to jar file
# $2 : class to view
# unzips the jar to tmp, opens the arguement class file, clears tmp
function srcview {
  unzip -q $1 $2 -d /tmp
  emacs /tmp/$2 && rm /tmp/$2
}

# $1 : path to jar to be indexed
#  Helper to index function. Handles an individual file
#  output is "fully-qualified-class  jar-file-path"
function index-src-jar {
  for cl in `jar -tf "$1"`
  do
    if [[ "$cl" =~ ".*\.java" ]]
      then echo $cl $1 >> ~/.repo_index.txt
    fi
  done
}

function index-jar {
  for cl in `jar -tf "$1"`
  do
    if [[ "$cl" =~ ".*\.class" ]]
      then echo $cl $1 >> ~/repo_index.txt
    fi
  done
}

# Produces ~/.repo_index.txt file
function index {
  rm ~/.repo_index.txt
  touch ~/.repo_index.txt
  for jar in `ls $(bazel info output_base)/external/**/*-src.jar`
  do index-src-jar $jar
  done
}

# $1 : the classname we want to inspect
# Calls srcview on the line of .repo_index.txt that matches the argument class
function inspect {
  srcview `grep $1 ~/.repo_index.txt | awk '{print $2 " " $1}'`
}
function inspect-completions {
  reply=($(grep $1 ~/.repo_index.txt | awk '{print $1}' | xargs basename))
}
compctl -K inspect-completions inspect
