fastbill-client
===============

Promise based Fastbill client in node.js with additional convenience methods

This is a fork of [https://github.com/passionkind/fastbill-client](https://github.com/passionkind/fastbill-client) which [has a pending PR](https://github.com/passionkind/fastbill-client/pull/2) that doesn't get merged. Hence a re-publish to npm is needed to get the updated code.

RESTful API-Client for Fastbill that covers all existing interfaces by using a descriptor file. Based on the descriptor, the module generates a node-style API by using Q's promise implementation, request module and lodash.

API USAGE
----------

### Initializing the client
This client must be initialized by using the
```js
fastbill = require('fastbill-client');
fastbill.bootstrap(username, password);
```

### Accessing fastbill's API
After the client has set authentication details, it can be used by simply calling
```js
fastbill.api.entity.verb
```
whereas entity reflects fastbill's entity names (e. g. "customer" or "invoice") and verb reflects the method the is to be used (e. g. "get", "create").

Those methods are promised based and require different parameters based on the method.

### GET-Methods
All get-methods expect at least a filter object (see fastbill API documentation). You can furthermore add an offset as second parameter and a limit as the third one:

```js
fastbill.api.invoice.get({filter: {"INVOICE_ID": "XXXXX"}, limit, offset})
```

### GET-Convenience Methods
Convenience methods like getById or getByNumber etc. must not be provided with a filter object but instead with the field value that the according filter is meant for:

```js
fastbill.api.invoice.getById("ID", limit, offset)
```

whereas those methods also accept multiple field values as an array:

```js
fastbill.api.invoice.getById(["ID1", "ID2", "ID3"], limit, offset)
```

### CREATE, UPDATE, DELETE etc.
All other methods besides previously mentioned getters, accept a data object only that must reflect fastbill's API specification.

```js
fastbill.api.invoice.create({"CUSTOMER_ID": "XXXXXX", "ITEMS": [{"ARTICLE_NUMBER": "1", "QUANTITY": "4"}]})
```

### Promised example
```js
fastbill.api.invoice.create({
  "CUSTOMER_ID": "1016354"
  "ITEMS": [
    {
      "ARTICLE_NUMBER": "1",
      "QUANTITY": 3
    }
  ]  
}).then(
  (result) ->
    console.log result
  (err) ->
    console.log err
)

fastbill.api.invoice.getByNumber("3").then(
  (result) ->
    console.log result
  (err) ->
    console.log err
)
```



API COVERAGE
----------

```json
{ customer:
   {
     get: [Function],
     update: [Function],
     delete: [Function],
     getByCustomerId: [Function],
     getById: [Function],
     getByCustomerNumber: [Function],
     getByNumber: [Function],
     getByCountryCode: [Function],
     getByCity: [Function],
     getByTerm: [Function]
    },
  estimate:
   { create: [Function],
     delete: [Function],
     sendbyemail: [Function],
     createinvoice: [Function],
     get: [Function],
     getByEstimateId: [Function],
     getById: [Function],
     getByCustomerId: [Function],
     getByEstimateNumber: [Function],
     getByNumber: [Function],
     getByStartEstimateDate: [Function],
     getByStartDate: [Function],
     getByEndEstimateDate: [Function],
     getByEndDate: [Function],
    },
  invoice:
   { create: [Function],
     get: [Function],
     getByInvoiceId: [Function],
     getById: [Function],
     getByInvoiceNumber: [Function],
     getByNumber: [Function],
     getByInvoiceTitle: [Function],
     getByTitle: [Function],
     getByCustomerId: [Function],
     getByMonth: [Function],
     getByYear: [Function],
     getByStartDueDate: [Function],
     getByEndDueDate: [Function],
     getByState: [Function],
     getByType: [Function],
     update: [Function],
     delete: [Function],
     complete: [Function],
     cancel: [Function],
     sign: [Function],
     sendbyemail: [Function],
     sendbypost: [Function],
     setpaid: [Function]
    },
  item:
   { get: [Function],
     getByInvoiceId: [Function],
     delete: [Function]
    },
  recurring:
   { create: [Function],
     get: [Function],
     getByInvoiceId: [Function],
     getByInvoiceNumber: [Function],
     getByInvoiceTitle: [Function],
     getByCustomerId: [Function],
     getByMonth: [Function],
     getByYear: [Function],
     getByStartDueDate: [Function],
     getByEndDueDate: [Function],
     getByState: [Function],
     getByType: [Function],
     update: [Function],
     delete: [Function]
    },
  revenue:
   { create: [Function],
     get: [Function],
     getByInvoiceId: [Function],
     getByInvoiceNumber: [Function],
     getByInvoiceTitle: [Function],
     getByCustomerId: [Function],
     getByMonth: [Function],
     getByYear: [Function],
     getByStartDueDate: [Function],
     getByEndDueDate: [Function],
     getByState: [Function],
     getByType: [Function],
     update: [Function],
     delete: [Function]
    },
  expense:
   { create: [Function],
     get: [Function],
     getByInvoiceId: [Function],
     getByInvoiceNumber: [Function],
     getByMonth: [Function],
     getByYear: [Function]
    },
  article:
   { create: [Function],
     get: [Function],
     getByArticleNumber: [Function],
     getByNumber: [Function],
     update: [Function],
     delete: [Function]
    },
  document: { create: [Function] },
  project:
   { create: [Function],
     get: [Function],
     getByProjectId: [Function],
     getById: [Function],
     getByCustomerId: [Function],
     update: [Function],
     delete: [Function]
    },
  time:
   { create: [Function],
     get: [Function],
     getByTimeId: [Function],
     getById: [Function],
     getByCustomerId: [Function],
     getByProjectId: [Function],
     getByTaskId: [Function],
     getByStartDate: [Function],
     getByEndDate: [Function],
     getByDate: [Function],
     update: [Function],
     delete: [Function]
    }
  },
  template:
  {
    get: [Function]
  }
```
