function tdir --description "Create a temporary directory and change to it"
      set dir (mktemp -d tmpdir.XXXX)
      set cur_dir $PWD
      cd $dir
      fish
      cd $cur_dir
      rm -rf $dir
end