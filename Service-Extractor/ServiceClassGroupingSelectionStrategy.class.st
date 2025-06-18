Class {
	#name : 'ServiceClassGroupingSelectionStrategy',
	#superclass : 'ServiceSelectionStrategy',
	#instVars : [
		'ucClasses'
	],
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'computing' }
ServiceClassGroupingSelectionStrategy >> nextMethodsToExtract [
	"Select all methods from a random UC class"

	| ucClass |
	ucClass := self ucClasses atRandom.
	ucClasses remove: ucClass.

	^ ucClass methods select: [ :m | simulation entryMethods includes: m ]
]

{ #category : 'computing' }
ServiceClassGroupingSelectionStrategy >> ucClasses [

	^ ucClasses ifNil: [
		  ucClasses := (simulation model allModelClasses
			               select: [ :c |
				               (c name beginsWith: 'Uc' caseSensitive: false)
					               and: [
						               (c name endsWith: 'Impl' caseSensitive: false)
							               and: [
							               (c name
								                includesSubstring: 'usine'
								                caseSensitive: false) not ] ] ])
			                asOrderedCollection ]
]
