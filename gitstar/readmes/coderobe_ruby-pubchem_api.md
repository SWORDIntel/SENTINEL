# PubChemAPI Ruby Library

A comprehensive Ruby library for interacting with the [PubChem PUG REST API](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest). This library provides a user-friendly interface to access PubChem data and services, mapping API responses onto Ruby classes for seamless integration into your applications.


**Warning:** This implementation is unfinished and has known issues. Basic usage is functional, no guarantees beyond that.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Initialization](#initialization)
  - [Usage Examples](#usage-examples)
    - [Retrieve Compound Data by CID](#retrieve-compound-data-by-cid)
    - [Retrieve Compound Data by Name](#retrieve-compound-data-by-name)
    - [Perform a Similarity Search](#perform-a-similarity-search)
    - [Retrieve Taxonomy Summary by TaxID](#retrieve-taxonomy-summary-by-taxid)
- [Available Methods](#available-methods)
- [Error Handling](#error-handling)
- [License](#license)

## Features

- **Comprehensive Endpoint Coverage**: Access various PubChem resources such as compounds, substances, assays, genes, proteins, and more.
- **Object Mapping**: API responses are mapped to Ruby classes, allowing easy access to data without handling raw JSON or XML.
- **Error Handling**: Custom `APIError` class provides detailed error messages and codes.
- **Parameter Validation**: Ensures that only valid parameters are sent to the API.
- **Extensible Design**: The code structure should make it easy to extend the library with additional endpoints or complex data mapping, in case something is missing.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'pubchem_api'
```

Or install it yourself as:

```bash
$ gem install pubchem_api
```

**Note**: This gem depends on httparty and nokogiri

```bash
$ gem install httparty nokogiri
```

## Getting Started

### Initialization

Require the library in your Ruby script:

```ruby
require 'pubchem_api'
```

Initialize the client:

```ruby
client = PubChemAPI::Client.new
```

### Usage Examples

#### Retrieve Compound Data by CID

```ruby
begin
  compound = client.get_compound_by_cid(2244, 'record')
  puts "CID: #{compound.cid}"
  puts "Molecular Formula: #{compound.molecular_formula}"
  puts "Molecular Weight: #{compound.molecular_weight}"
  puts "Canonical SMILES: #{compound.canonical_smiles}"
  puts "InChIKey: #{compound.inchi_key}"
rescue PubChemAPI::APIError => e
  puts "API Error (#{e.code}): #{e.message}"
end
```

#### Retrieve Compound Data by Name

```ruby
begin
  compound = client.get_compound_by_name('aspirin', 'record')
  puts "CID: #{compound.cid}"
  puts "Molecular Formula: #{compound.molecular_formula}"
  puts "Molecular Weight: #{compound.molecular_weight}"
rescue PubChemAPI::APIError => e
  puts "API Error (#{e.code}): #{e.message}"
end
```

#### Perform a Similarity Search

```ruby
begin
  options = {}
  options['Threshold'] = 90
  results = client.compound_structure_search(
    'fastsimilarity_2d',
    'smiles',
    'CC(=O)OC1=CC=CC=C1C(=O)O',
    'JSON',
    options
  )
  cids = results['IdentifierList']['CID']
  puts "Found CIDs: #{cids.join(', ')}"
rescue PubChemAPI::APIError => e
  puts "API Error (#{e.code}): #{e.message}"
end
```

#### Retrieve Taxonomy Summary by TaxID

```ruby
begin
  taxonomy = client.get_taxonomy_summary_by_taxid(9606)
  puts "Scientific Name: #{taxonomy.scientific_name}"
  puts "Common Name: #{taxonomy.common_name}"
  puts "Rank: #{taxonomy.rank}"
rescue PubChemAPI::APIError => e
  puts "API Error (#{e.code}): #{e.message}"
end
```

## Available Methods

### Compounds

- `get_compound_by_cid(cid, operation, output = DEFAULT_OUTPUT, options = {})`
- `get_compound_by_name(name, operation, output = DEFAULT_OUTPUT, options = {})`
- `get_compound_conformers(cid, output = DEFAULT_OUTPUT, options = {})`
- `compound_structure_search(search_type, namespace, identifier, output = DEFAULT_OUTPUT, options = {})`

### Substances

- `get_substance_by_sid(sid, operation, output = DEFAULT_OUTPUT, options = {})`

### Assays

- `get_assay_by_aid(aid, operation, output = DEFAULT_OUTPUT, options = {})`
- `get_assay_doseresponse(aid, output = DEFAULT_OUTPUT, options = {})`
- `get_assay_targets(aid, target_type, output = DEFAULT_OUTPUT, options = {})`

### Genes

- `get_gene_summary_by_geneid(geneid, output = DEFAULT_OUTPUT, options = {})`
- `get_gene_summary_by_synonym(synonym, output = DEFAULT_OUTPUT, options = {})`

### Proteins

- `get_protein_summary_by_synonym(synonym, output = DEFAULT_OUTPUT, options = {})`

### Taxonomy

- `get_taxonomy_summary_by_taxid(taxid, output = DEFAULT_OUTPUT, options = {})`

### Pathways

- `get_pathway_summary_by_pwacc(pwacc, output = DEFAULT_OUTPUT, options = {})`

### Classification

- `get_classification_nodes(hnid, idtype, output = DEFAULT_OUTPUT, list_return, options = {})`

### Lists and Pagination

- `get_compounds_by_listkey(listkey, output = DEFAULT_OUTPUT, options = {})`

## Error Handling

The library raises a `PubChemAPI::APIError` exception for API errors:

```ruby
begin
  # API call
rescue PubChemAPI::APIError => e
  puts "API Error (#{e.code}): #{e.message}"
end
```

`APIError` definition:

- `APIError.code`: HTTP status code
- `APIError.message`: Error message from the API


## License

This project is licensed under the [MIT License](LICENSE).

---

*Disclaimer: This library is not affiliated with or endorsed by PubChem. Use responsibly.*
