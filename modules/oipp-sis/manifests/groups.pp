#
# group resources for OIPP SIS integration
#
class oipp-sis::groups {

    # sis csv upload accounts
    @group { 'ucd_sis' : gid => '801' }
    @group { 'ucb_sis' : gid => '802' }
    @group { 'ucm_sis' : gid => '803' }
    @group { 'ucla_sis': gid => '804' }
}
