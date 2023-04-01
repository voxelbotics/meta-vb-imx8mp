# Input parameters:
#
# MFGBUNDLE_MAP
#       A list of <source>:<dest> entries to form a bundle from.
#
# MFGBUNDLE_KERNEL
#       Mfgtool-enabled kernel recipe. Adds build depenency on this recipe.
#
# MFGBUNDLE_INITRD
#       Mfgtool-enabled initramfs recipe. Adds build depenency on this recipe.
#
# MFGBUNDLE_EXTRA_DEPS
#       Additional build dependencies.
#
# MFGBUNDLE_DEPTASKS
#       Image tasks which should be complete before assembling the bundle.
#
# MFGBUNDLE_ZIPOPT
#       A colon-separated lists of file suffixes to store as is without compression.

# where source artifacts are looked for
MFGBUNDLE_SEARCH_PATH ?= "${FILESPATH}:${BBPATH}:${IMGDEPLOYDIR}:${DEPLOY_DIR_IMAGE}"

# where links to source files are created
MFGBUNDLE_TMPDIR = "${WORKDIR}/mfgtool-bundle-build"

# by default depend only on mfgtool kernel and initramfs
MFGBUNDLE_DEPS = "${MFGBUNDLE_KERNEL} ${MFGBUNDLE_INITRD} ${MFGBUNDLE_EXTRA_DEPS}"
MFGBUNDLE_EXTRA_DEPS ?= ""

# by default run after the tar and wic images are done
MFGBUNDLE_DEPTASKS ?= "do_image_tar do_image_wic"

# don't try compressing file with these suffixes
MFGBUNDLE_ZIPOPT ?= ".bz2:.zst:.gz:.zip:.initrd"

DEPENDS += "zip-native"

python do_mfgtool_bundle() {
    import subprocess

    # link source file to a target one, or expand the source template into target
    def link_or_expand(src, dst, paths):
        # locate the source
        if os.path.exists(src):
            abs_src = src
        else:
            abs_src, attempts = bb.utils.which(paths, src, history=True)

        if not abs_src:
            bb.fatal("Source file '%s' is not found." % src)

        bb.note("Located '%s' at '%s'" % (src, abs_src))

        # strip dirs
        src = os.path.basename(src)
        dst = os.path.basename(dst)

        # append destination dir
        abs_dst = os.path.join(d.getVar('MFGBUNDLE_TMPDIR'), dst)

        # check if source is a template
        if src.endswith('.in'):
            bb.note("Expand '%s' to '%s'" % (abs_src, abs_dst))
            src, none = os.path.splitext(src)
            with open(abs_src, 'r') as f:
                body = f.read()
                # expand all variables
                body = d.expand(body)
                bb.note("Expanded source:\n%s" % body)
            # write to destination
            with open(abs_dst, 'w') as f:
                f.write(body)
        else:
            bb.note("Link '%s' to '%s'" % (abs_src, abs_dst))
            os.symlink(abs_src, abs_dst)

    entries = d.getVar('MFGBUNDLE_MAP').split()
    paths = d.getVar('MFGBUNDLE_SEARCH_PATH')

    for p in entries:
        pair = p.split(':')

        if len(pair) == 2:
            src = pair[0]
            dst = pair[1]
        else:
            src = pair[0]
            dst = pair[0]
        link_or_expand(src, dst, paths)

    bundle_zip = d.getVar('IMAGE_NAME') + '-mfgbundle.zip'
    cmd = 'cd %s  && zip -n %s %s *' % (
        d.getVar('MFGBUNDLE_TMPDIR'),
        d.getVar('MFGBUNDLE_ZIPOPT'),
        os.path.join(d.getVar('IMGDEPLOYDIR'), bundle_zip)
        )

    bb.note("exec_cmd: %s" % cmd)

    # create bundle zip
    subprocess.check_output(cmd, shell = True)

    # create bundle link
    bundle_link = d.getVar('IMAGE_LINK_NAME') + '-mfgbundle.zip'
    abs_bundle_link = os.path.join(d.getVar('IMGDEPLOYDIR'), bundle_link)
    if os.path.exists(abs_bundle_link):
        os.remove(abs_bundle_link)
    os.symlink(bundle_zip, abs_bundle_link)
}

# clean before each run
do_mfgtool_bundle[cleandirs] = "${MFGBUNDLE_TMPDIR}"

# add task dependencies
do_mfgtool_bundle[depends] += "${@' '.join('%s:do_build' % r for r in d.getVar('MFGBUNDLE_DEPS').split())}"

python () {
    if d.getVar('MFGBUNDLE_MAP'):
        bb.build.addtask('do_mfgtool_bundle', 'do_image_complete', d.getVar('MFGBUNDLE_DEPTASKS'), d)
}
