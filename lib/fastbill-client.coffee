fs      = require 'fs'
request = require 'request'
q       = require 'q'
_       = require 'lodash'

# parse descriptor file
api_description = JSON.parse(fs.readFileSync(__dirname + '/fastbill-api-description.json', 'utf8'))

api = {}
credentials = null
 

# ===========================================================================================
# HELPERS 

formatString = (a = "") ->
  return a.substr(0,1).toUpperCase() + a.substr(1, a.length).toLowerCase()

createAccessorFromArray = (array) ->
  if array.length == 1 then array.push ""
  return _.reduce array, (result, partial, key) ->
    if key == 1 then return formatString(result) + formatString(partial)
    else return result + formatString(partial)


createQueryFunction = (payload, entityName) ->
  
  deferred = q.defer()
  if !credentials then deferred.reject "Credentials not set"

  request {method: "POST", auth: credentials, uri: api_description.endpoint, body: JSON.stringify(payload)}, (err, response, body) ->
    # fastbill returns error in the following format :
    # ERRORS: {
    #   "X": "message"
    # }
    # whereas X := error number and message := error message
    
    # replicate fastbill error behavior for request module
    if err then return deferred.reject {"REQUEST_ERROR": err}
    else
      # parse body to JSON object
      body = JSON.parse(body)
      
      # return errors if there are any
      if body.RESPONSE && body.RESPONSE.ERRORS then return deferred.reject body["RESPONSE"]["ERRORS"]
        
      # if a get service was used, return entity array by using entityName appended by "S"
      if entityName then return deferred.resolve body["RESPONSE"]["#{entityName.toUpperCase()}S"]
        
      # if any other method was used (create, update, delete or e.g. setpaid)
      else return deferred.resolve JSON.parse(body)["RESPONSE"]
    
  return deferred.promise

  
  
# ===========================================================================================
# GENERATE API 
_.forEach api_description.services, (entityObject, entityName) ->

  serviceAPI = {}

  _.forEach entityObject.verbs, (verb) ->
    # if it's not the verbs attribute, use it as convenience method (getById, updateById, getByNumber, updateByNumber)
    if verb != "get" then serviceAPI[verb] = (data) ->
      payload =
        service: "#{entityName}.#{verb}"
        data: data

      return createQueryFunction(payload)
      # create regular serviceMethod (param = object)

    else # == get method, include convenience accessors

      # method A) create regular get with object as value (can contain filter, offset, limit) whereas offset and limit is optional
      #
      # method B) serviceName.get(filterValueOrValueArray) ==> only filter
      # method B1) serviceName.get(filterValueOrValueArray, offset, limit) ==> no additional filter
      # whereas both specify "service": "serviceName.get"
      # 
      # additions for A1 = filter, offset, limit
      # {
      #   service: "serviceName.get"
      #   filter: the accessor (only one field as filter - if more are required, the generic get is to be used!)
      #   offset: offset
      #   limit: limit
      # }
      #
      #
      # if the filterField contains the serviceName, we strip it out and offer BOTH methods (with and without the serviceName)
      # e.g.: customer.getById and customer.getByCustomerId
      # e.g.: customer.getByNumber and customer.getByCustomerNumber
      # 

      # create convenience accessors

      getAccessors = []

      # create default get method

      serviceAPI["get"] = (filterObject, offset = 0, limit = 100) ->
        payload =
          service: "#{entityName}.#{verb}"
          offset: offset
          limit: limit
          filter: filterObject

        return createQueryFunction(payload, entityName)

      _.forEach entityObject.get_filter, (fieldName) ->
        # create Accessor
        fieldPartials = fieldName.split('_')

        getAccessors.push({accessor: createAccessorFromArray(fieldPartials), filter: fieldName})

        # check if Accessor contains serviceName and strip it out and create convenience method
        length = fieldPartials.length
        fieldPartials = _.pull fieldPartials, entityName.toUpperCase()
  
        if length != fieldPartials.length then getAccessors.push({accessor: createAccessorFromArray(fieldPartials), filter: fieldName})

      _.forEach getAccessors, (accessorObject) ->
        serviceAPI["getBy#{accessorObject.accessor}"] = (filterValueOrValueArray, offset = 0, limit = 100) ->
          payload =
            service: "#{entityName}.#{verb}"
            offset: offset
            limit: limit
            filter: {}

          payload.filter["#{accessorObject.filter}"] = filterValueOrValueArray
        
          return createQueryFunction(payload, entityName)
     
  api[entityName] = serviceAPI


module.exports = 
  api: api
  bootstrap: (username, password) ->
    if username and password then return credentials = {"user": username, "pass": password}
    else return credentials = null
