INDEX = 'logstash-logs-*'

QUERY_MATCH_ALL = {
    "query": {
        "match_all": {}
    },
    "size": 10000,  # 필요한 로그 수에 따라 조정
    "sort": [{"@timestamp": {"order": "desc"}}] 
}