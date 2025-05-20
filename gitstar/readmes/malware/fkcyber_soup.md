# soup

**Web Scraper in Go, similar to BeautifulSoup**

*soup* is a small web scraper package for Go, with its interface highly similar to that of BeautifulSoup.

Exported variables and functions implemented till now :

```go
var Headers map[string]string // Set headers as a map of key-value pairs, an alternative to calling Header() individually
var Cookies map[string]string // Set cookies as a map of key-value  pairs, an alternative to calling Cookie() individually
func GET(string, map[string]string) (string, error) {} // Takes the url and headers returns HTML string
func POST(string, interface{}, map[string]string) (string, error) {} // Takes the url, payload, and headers as string, interface{} and map (url, payload, headers)
func PostForm(string, url.Values) {} // Takes the url and body. bodyType is set to "application/x-www-form-urlencoded"
func Header(string, string) {} // Takes key,value pair to set as headers for the HTTP request made in Get()
func Cookie(string, string) {} // Takes key, value pair to set as cookies to be sent with the HTTP request in Get()
func HTMLParse(string) Root {} // Takes the HTML string as an argument, returns a pointer to the DOM constructed
func Find([]string) Root {} // Element tag,(attribute key-value pair) as argument, pointer to first occurence returned
func FindAll([]string) []Root {} // Same as Find(), but pointers to all occurrences returned
func FindStrict([]string) Root {} //  Element tag,(attribute key-value pair) as argument, pointer to first occurence returned with exact matching values
func FindAllStrict([]string) []Root {} // Same as FindStrict(), but pointers to all occurrences returned
func FindNextSibling() Root {} // Pointer to the next sibling of the Element in the DOM returned
func FindNextElementSibling() Root {} // Pointer to the next element sibling of the Element in the DOM returned
func FindPrevSibling() Root {} // Pointer to the previous sibling of the Element in the DOM returned
func FindPrevElementSibling() Root {} // Pointer to the previous element sibling of the Element in the DOM returned
func Children() []Root {} // Find all direct children of this DOM element
func Attrs() map[string]string {} // Map returned with all the attributes of the Element as lookup to their respective values
func Text() string {} // Full text inside a non-nested tag returned, first half returned in a nested one
func FullText() string {} // Full text inside a nested/non-nested tag returned
func SetDebug(bool) {} // Sets the debug mode to true or false; false by default
func HTML() {} // HTML returns the HTML code for the specific element
```

`Root` is a struct, containing three fields :

* `Pointer` containing the pointer to the current html node
* `NodeValue` containing the current html node's value, i.e. the tag name for an ElementNode, or the text in case of a TextNode
* `Error` containing an error in a struct if one occurrs, else `nil` is returned. 
  A detailed text explaination of the error can be accessed using the `Error()` function. A field `Type` in this struct of type `ErrorType` will denote the kind of error that took place, which will consist of either of the following
  * `ErrUnableToParse`
  * `ErrElementNotFound`
  * `ErrNoNextSibling`
  * `ErrNoPreviousSibling`
  * `ErrNoNextElementSibling`
  * `ErrNoPreviousElementSibling`
  * `ErrCreatingGetRequest`
  * `ErrInGetRequest`
  * `ErrReadingResponse`

## Installation

Install the package using the command

```bash
go get github.com/fkcyber/soup
```

## Examples

An example code is given below to scrape the "Comics I Enjoy" part (text and its links) from [xkcd](https://xkcd.com).

```go
package main

import (
    "fmt"
    "os"

    "github.com/fkcyber/soup"
)

// can initialize empty headers & payloads too like this:
/*
emptyPayload := interface{}
noSpecifiedHeaders := map[string]string
*/

func main() {
    emptyPayload := interface{}
    noSpecifiedHeaders := map[string]string
    resp, err := soup.GET("https://xkcd.com", emptyPayload, noSpecifiedHeaders)
    if err != nil {
        os.Exit(1)
    }
    doc := soup.HTMLParse(resp)
    links := doc.Find("div", "id", "comicLinks").FindAll("a")
    for _, link := range links {
        fmt.Println(link.Text(), "| Link :", link.Attrs()["href"])
    }
}
```

```go
package main

import (
	"bytes"
	"encoding/json"
	"net/http"

    "github.com/fkcyber/soup"
)

// impossible to send POST without data/payload/request/info

func main() {
	webhookURL := "YOUR_DISCORD_WEBHOOK_URL"
    headers := map[string]string{
        "Content-Type": "application/json",
    }
	data := map[string]string{
		"content": "testing soup.POST() at [fkcyber/soup](https://github.com/fkcyber/soup) with webhooks",
	}
	payload, err := json.Marshal(data)
	if err != nil {
		panic(err)
	}

	req, err := soup.POST(webhookURL, bytes.NewBuffer(payload), headers)
	if err != nil {
		panic(err)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
}
```
