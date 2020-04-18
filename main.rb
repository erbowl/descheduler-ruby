require 'k8s-client'

def client
  @client ||= K8s::Client.config(
    K8s::Config.load_file(
      File.expand_path '~/.kube/config'
    )
  )
end

$threads = {}

def handler(resource:, type:)
  self_link = resource.metadata.selfLink
  if $threads[self_link]
    $threads[self_link].exit
    $threads.delete self_link
  end
  return if type == "DELETED"
  $threads[self_link] = Thread.new {
    loop do
      begin
        client.api('v1').resource('pods').list(labelSelector: resource.spec.selector.to_hash).each do |pod|
          if Time.parse(pod.metadata.creationTimestamp) < Time.new - resource.spec.lifetimeMinutes.to_i*60 
            puts "deleting... namespace=#{pod.metadata.namespace} pod: #{pod.metadata.name} node=#{pod.spec.nodeName}"
            client.api('v1').resource('pods', namespace: pod.metadata.namespace).delete(pod.metadata.name)
            break
          end 
        end
        sleep resource.spec.intervalMinutes.to_i*60
      rescue e
        pp e
      end
    end
  }
end

client.api('erbowl.com/v1beta').resource('deschedulers').watch do |watch_event|
  handler(
    resource: watch_event.resource,
    type: watch_event.type
  )
end
