import pygbif

print(pygbif.__version__)

splist = ['Cyanocitta stelleri', 
          'Junco hyemalis', 
          'Aix sponsa',
          'Ursus americanus', 
          'Pinus conorta', 
          'Poa annuus']
keys = [pygbif.species.name_backbone(x)['usageKey'] for x in splist ]

"""
print(keys)
>>[2482598, 9362842, 2498387, 2433407, 5285750, 2704173]
"""

occRecords = [pygbif.occurrences.search(taxonKey=key, limit=10) for key in keys]
"""
print(occRecords[0].keys())
>>dict_keys(['offset', 'limit', 'endOfRecords', 'count', 'results', 'facets'])
"""

for key in occRecords[0].keys():
    print(key, occRecords[0][key])