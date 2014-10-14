fs      = require 'fs'
request = require 'request'
q       = require 'q'
_       = require 'lodash'

api_description = JSON.parse(fs.readFileSync(__dirname + '/fastbill-api-description.json', 'utf8'))

#  (ESTIMATE_*)



# Build api client

api = {}



formatString = (a = "") -> 
  return a.substr(0,1).toUpperCase() + a.substr(1, a.length).toLowerCase()
    
    
_.forEach api_description.services, (service, serviceName) ->
  
  serviceAPI = {}
  
  _.forEach service.verbs, (verb) ->   
    # if it's not the verbs attribute, use it as convenience method (getById, updateById, getByNumber, updateByNumber)
    if verb != "get" then serviceAPI[verb] = (data) ->
      console.log data
    else # == get method, include convenience accessors
      serviceAPI.get = (data) ->
        console.log data
      _.forEach service.get_filter, (fieldName) ->
        splitArray = fieldName.split('_')
        
        if splitArray.length == 1 then accessor = formatString(splitArray[0])
        else          
          accessor = _.reduce splitArray, (result, partial) ->       
            if result.toLowerCase() == serviceName.toLowerCase() then return formatString(partial)
            else return formatString(result) + formatString(partial) 

        serviceAPI["getBy#{accessor}"] = (value) ->
          #console.log {filter: {fieldName: value}}
          return

  api[serviceName] = serviceAPI

  
console.log api

module.exports = api_description