Class {
	#name : 'MiServiceExtractorModel',
	#superclass : 'MiAbstractModel',
	#instVars : [
		'methodList',
		'extractionDictionary',
		'elementIndex',
		'methodToExtract',
		'uccg',
		'extractions'
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

{ #category : 'accessing' }
MiServiceExtractorModel >> currentExtract [

	^ self extractionDictionary at: self methodToExtract
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
MiServiceExtractorModel >> methodToExtract [

	^ methodToExtract
]

{ #category : 'accessing' }
MiServiceExtractorModel >> methodToExtract: aFamixJavaMethod [

	methodToExtract := aFamixJavaMethod
]

{ #category : 'accessing' }
MiServiceExtractorModel >> miSelectedItem [

	^ {  }
]

{ #category : 'accessing' }
MiServiceExtractorModel >> uccg [

	^ uccg
]

{ #category : 'accessing' }
MiServiceExtractorModel >> uccg: anObject [

	uccg := anObject
]
