require imx-image.inc
IMAGE_PREPROCESS_COMMAND:remove = "do_fix_connman_conflict;"
APTGET_EXTRA_PACKAGES:remove = "connman"
