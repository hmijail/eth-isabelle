The Dockerfile from 2018 didn't work because it wasn't kept updated while the rest of the repo evolved. So the 2024 version tries to push forward the versions of the various parts involved to try to get a buildable image.

Build the image with:
docker build -f Dockerfile2024 -t ethisa24

Fails in the last step (which seems to try to run tests?) during OCaml compilation:
```
ocamlfind ocamlc -c -g -package rlp -package ecc -package batteries -package bignum -package yojson -package secp256k1 -I lem -o lem/word64.cmo lem/word64.ml
+ ocamlfind ocamlc -c -g -package rlp -package ecc -package batteries -package bignum -package yojson -package secp256k1 -I lem -o lem/word64.cmo lem/word64.ml
ocamlfind: [WARNING] Package `threads': Linking problems may arise because of the missing -thread or -vmthread switch
File "lem/word64.ml", line 174, characters 52-74:
174 | let word64Power a b:Int64.t=  (gen_pow(Int64.of_int (Nat_big_num.of_int 1)) Int64.mul a b)
                                                          ^^^^^^^^^^^^^^^^^^^^^^
Error: This expression has type Z.t but an expression was expected of type
         int
Command exited with code 2.
Error: building at STEP "RUN eval `opam config env` && ./compile.sh": while running runtime: exit status 10
```

If your Docker/Podman can't do sudo, please try changing binfmt config to fix it: [sudo in non-native container complains "effective uid is not 0" · containers/podman · Discussion #20445 · GitHub](https://github.com/containers/podman/discussions/20445#discussioncomment-7372474)

