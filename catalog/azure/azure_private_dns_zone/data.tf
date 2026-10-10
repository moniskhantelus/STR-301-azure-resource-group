# Existing VNet data sources belong to the caller; see examples/*/data.tf.
# The caller passes the returned VNet IDs through vnet_links.
# No redundant VNet reads here: IDs can also come from an aliased provider
# in a networking subscription. This module never owns networking resources.
