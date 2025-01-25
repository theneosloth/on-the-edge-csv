SHELL := /bin/sh
export PATH := $(shell nix develop --command sh -c 'echo $$PATH')

.PHONY: default
default: out.tsv

out.tsv:
	@sbcl --script main.lisp
