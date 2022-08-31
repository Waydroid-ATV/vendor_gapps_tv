$(call inherit-product, vendor/lineage/build/target/product/lineage_arm64.mk)

PRODUCT_NAME := lineage_gapps_tv_arm64

PRODUCT_USE_DYNAMIC_PARTITIONS := false
PRODUCT_SOONG_NAMESPACES += vendor/gapps_tv/overlay
