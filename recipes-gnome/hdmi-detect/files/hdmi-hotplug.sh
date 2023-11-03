#!/bin/sh
systemctl is-active gdm.service && systemctl restart gdm.service || systemctl start gdm.service
