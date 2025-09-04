Class {
	#name : 'MiServiceExtractorModel',
	#superclass : 'MiAbstractModel',
	#instVars : [
		'methodList',
		'extractionDictionary',
		'elementIndex',
		'uccg',
		'extractions',
		'incrementalMigration',
		'methodsToExtract',
		'currentService'
	],
	#category : 'Service-Extractor-Browser',
	#package : 'Service-Extractor',
	#tag : 'Browser'
}

{ #category : 'adding' }
MiServiceExtractorModel >> addExtraction: anExtraction [

	extractions add: anExtraction
]

{ #category : 'accessing' }
MiServiceExtractorModel >> buildCallGraph [

	uccg := Smalltalk at: #uccg ifAbsentPut: [
		        JavaCallGraphModel new
			        entryMethods: self methodList;
			        cha;
			        computeDominators;
			        computeDominatorTree;
			        yourself ].
]

{ #category : 'as yet unclassified' }
MiServiceExtractorModel >> computeSolutions [

	incrementalMigration extract: methodList
]

{ #category : 'accessing' }
MiServiceExtractorModel >> currentService [

	^ currentService
]

{ #category : 'accessing' }
MiServiceExtractorModel >> currentService: anObject [

	currentService := anObject
]

{ #category : 'as yet unclassified' }
MiServiceExtractorModel >> currentSolutions [

	^ incrementalMigration currentSolutions
]

{ #category : 'accessing' }
MiServiceExtractorModel >> elementIndex [

	^ elementIndex ifNil: [
		  elementIndex := Dictionary new.
		  self extractionDictionary associationsDo: [ :assoc |
			  | m ext |
			  m := assoc key.
			  ext := assoc value.
			  ext valuesDo: [ :v |
				  v do: [ :famixElt |
					  elementIndex
						  at: famixElt
						  ifPresent: [ :c | c add: m ]
						  ifAbsentPut: [ Set with: m ] ] ] ].
		  elementIndex ]
]

{ #category : 'accessing' }
MiServiceExtractorModel >> entities [

	^ {  }
]

{ #category : 'accessing' }
MiServiceExtractorModel >> extractionDictionary [

	^ extractionDictionary ifNil: [
		  extractionDictionary := Dictionary new.
		  methodList do: [ :m |
			  extractionDictionary
				  at: m
				  put: (ServiceExtractor extractMethod: m) ].
		  extractionDictionary ]
]

{ #category : 'accessing' }
MiServiceExtractorModel >> extractions [

	^ extractions
]

{ #category : 'accessing' }
MiServiceExtractorModel >> extractions: anObject [

	extractions := anObject
]

{ #category : 'initialization' }
MiServiceExtractorModel >> initialize [

	super initialize.
	extractions := OrderedCollection new.
	incrementalMigration := IncrementalMigration current.
	Smalltalk at: #allExtractions ifPresent: [ :e | extractions addAll: e ]
]

{ #category : 'accessing' }
MiServiceExtractorModel >> methodList [

	^ methodList
]

{ #category : 'accessing' }
MiServiceExtractorModel >> methodList: anObject [

	methodList := anObject
]

{ #category : 'accessing' }
MiServiceExtractorModel >> methodsToExtract [

	^ methodsToExtract
]

{ #category : 'accessing' }
MiServiceExtractorModel >> methodsToExtract: anObject [

	methodsToExtract := anObject
]

{ #category : 'accessing' }
MiServiceExtractorModel >> miSelectedItem [

	^ {  }
]

{ #category : 'building' }
MiServiceExtractorModel >> saveIncrement [

	incrementalMigration saveIncrementFromService: currentService
]

{ #category : 'accessing' }
MiServiceExtractorModel >> services [

	| s |
	s := OrderedCollection withAll:
		     (incrementalMigration increments collect: [ :increment |
			      increment extractedService ]).
	currentService ifNotNil: [ s add: currentService ].
	^ s
]

{ #category : 'initialization' }
MiServiceExtractorModel >> setServiceFromSolution: aSolution [

	currentService := incrementalMigration serviceFromSolution: aSolution
]

{ #category : 'accessing' }
MiServiceExtractorModel >> uccg [

	^ Smalltalk at: #uccg
]

{ #category : 'accessing' }
MiServiceExtractorModel >> uccg: anObject [

	uccg := anObject
]
