output "endpoint" {
  value       = "${aws_elasticsearch_domain.voice-services-es.endpoint}"
  description = "Elasticsearch Domian "
}

output "kibana_endpoint" {
  value       = "${aws_elasticsearch_domain.voice-services-es.kibana_endpoint}"
  description = "Kibana Endpoints"
}
