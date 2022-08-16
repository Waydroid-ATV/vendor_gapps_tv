$(call inherit-product, build/target/product/aosp_arm.mk)

include vendor/lineage/build/target/product/lineage_generic_target.mk

TARGET_NO_KERNEL_OVERRIDE := true
PRODUCT_USE_DYNAMIC_PARTITIONS := false

PRODUCT_NAME := lineage_gapps_tv_arm

PRODUCT_SOONG_NAMESPACES += vendor/gapps_tv/overlay
