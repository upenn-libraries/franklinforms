# Franklin Forms

Franklin Forms is a Rails app that provides various forms and interfaces to patrons for making requests, asking for help from staff, and viewing information on resource sharing.

## Dependencies

* Ruby 2.3.1
* Rails 5
* Oracle Instant Client 12.1
* libaio1
* Docker
* Docker Compose

## Installation

1. Clone the repository.
1. Copy ``.env.example`` to ``.env``.
1. Open ``.env`` set the values for each variable. Each variable is documented in the file.

Now you can run the Rails server to access the forms or execute the following to run the forms with Docker:

```bash
docker-compose up .
```

## Paths

Franklin Forms has two top-level paths:

* **/redir:** Most forms are initially linked under this path and are redirected to an analagous path under **/forms** or an external service such as Ares or Aeon. This is done when additional information needs to be retrieved before handling the request, such as referrer information or OpenURL data. "Need Help?" is linked here and does not redirect.
* **/forms:** Most form requests end up under this path. The resource sharing page is also under here.

## Forms / Interfaces

Franklin Forms provides the following request options and interfaces:

| Option | Notes |
|---|---|
| Books by Mail | appears in fulfillment iframe and on Services page |
| FacultyEXPRESS | appears in fulfillment iframe and on Services page |
| Fix OPAC Request | appears in fulfillment iframe and on Services page |
| ILL | appears in fulfillment iframe and on Services page |
| Need Help? | appears on Services page |
| Place on Course Reserve | appears in fulfillment iframe and on Services page |
| Request Enhanced Cataloging | appears in fulfillment iframe and on Services page |
| Request to View | appears in Franklin |
| Resource Sharing | appears in Franklin and library website |

## Integration Points

Franklin Forms operates with the following services:

| Service | Notes |
|---|---|
| Aeon | for requesting to view special collection titles |
| Alma | for retrieving bibliographic information |
| Ares | for placing course reserves |
| BorrowDirect+ | for Relais authentication and linking to search interface |
| ILLiad | for placing various requests; interacts directly w/database and simulates browser activity |
| Library LDAP | for authorization and determining standing faculty status |
| Penn Community | for retrieving patron information |
