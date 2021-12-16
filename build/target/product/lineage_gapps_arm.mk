$(call inherit-product, vendor/lineage/build/target/product/lineage_arm.mk)

PRODUCT_NAME := lineage_gapps_arm

PRODUCT_USE_DYNAMIC_PARTITIONS := false
PRODUCT_SOONG_NAMESPACES += vendor/gapps/overlay
