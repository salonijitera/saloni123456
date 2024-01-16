if @error_object.present?
  json.status @status_code
  json.message @error_object
else
  json.status 200
  json.message 'Profile updated successfully.'
end
