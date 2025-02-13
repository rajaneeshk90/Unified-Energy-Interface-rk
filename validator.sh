#beckn-spec-validator -b api/l2.yaml -c paths./search.post.requestBody.content.application/json.schema -s examples/ev-charging/search/search-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_search.post.requestBody.content.application/json.schema -s examples/ev-charging/search/on_search-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./select.post.requestBody.content.application/json.schema -s examples/ev-charging/select/select-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_select.post.requestBody.content.application/json.schema -s examples/ev-charging/select/on_select-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./init.post.requestBody.content.application/json.schema -s examples/ev-charging/init/init-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_init.post.requestBody.content.application/json.schema -s examples/ev-charging/init/on_init-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./confirm.post.requestBody.content.application/json.schema -s examples/ev-charging/confirm/confirm-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_confirm.post.requestBody.content.application/json.schema -s examples/ev-charging/confirm/on_confirm-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./status.post.requestBody.content.application/json.schema -s examples/ev-charging/status/status-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_status.post.requestBody.content.application/json.schema -s examples/ev-charging/status/on_status-request.json

#beckn-spec-validator -b api/l2.yaml -c paths./update.post.requestBody.content.application/json.schema -s examples/ev-charging/update/update-request-charging-start.json
#beckn-spec-validator -b api/l2.yaml -c paths./update.post.requestBody.content.application/json.schema -s examples/ev-charging/update/update-request-charging-end.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_update.post.requestBody.content.application/json.schema -s examples/ev-charging/update/on_update-request-charging-start.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_update.post.requestBody.content.application/json.schema -s examples/ev-charging/update/on_update-request-charging-end.json
#beckn-spec-validator -b api/l2.yaml -c paths./support.post.requestBody.content.application/json.schema -s examples/ev-charging/support/support-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_support.post.requestBody.content.application/json.schema -s examples/ev-charging/support/on_support-request.json

#beckn-spec-validator -b api/l2.yaml -c #paths./rating.post.requestBody.content.application/json.schema -s examples/ev-charging/rating/rating-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_rating.post.requestBody.content.application/json.schema -s examples/ev-charging/rating/on_rating-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./cancel.post.requestBody.content.application/json.schema -s examples/ev-charging/cancel/cancel-request.json
#beckn-spec-validator -b api/l2.yaml -c paths./on_cancel.post.requestBody.content.application/json.schema -s examples/ev-charging/cancel/on_cancel-request.json
beckn-spec-validator -b api/l2.yaml -c paths./on_cancel.post.requestBody.content.application/json.schema -s examples/ev-charging/cancel/on_cancel-charger_breakdown-request.json
