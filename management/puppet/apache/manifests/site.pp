node 'puppet-agent.davidsdemo.com' {
  include apache
  include apache::vhosts
}
