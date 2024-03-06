"
A service extrator. It takes a famix method and give all (available at static time) entities needed to execute that service.
"
Class {
	#name : #ServiceExtractor,
	#superclass : #Object,
	#instVars : [
		'methodToExtract',
		'slicedClasses',
		'callGraph'
	],
	#category : #'Service-Extractor'
}

{ #category : #extraction }
ServiceExtractor >> attributesUsedBy: aMethod [

	| dependencies attributes |
	dependencies := Set new.
	attributes := (aMethod accesses
		               collect: #variable
		               thenSelect: [ :var | var isAttribute ]) asSet.
	"attributes do: [ :att |
		dependencies add: att.
		att incomingAccesses do: [ :access |
			access isWrite ifTrue: [ dependencies add: access accessor ] ] ]."
	^ attributes
]

{ #category : #extraction }
ServiceExtractor >> dependenciesOf: aMethod [

	| dependencies attributes |
	dependencies := Set new.
	attributes := (aMethod accesses
		               collect: #variable
		               thenSelect: [ :var | var isAttribute ]) asSet.
	"attributes do: [ :att |
		dependencies add: att.
		att incomingAccesses do: [ :access |
			access isWrite ifTrue: [ dependencies add: access accessor ] ] ]."
	^ attributes
]

{ #category : #extraction }
ServiceExtractor >> extract [

	| cgm |
	slicedClasses := Dictionary new.

	cgm := JavaCallGraphModel new
		       entryMethod: self methodToExtract;
		       yourself.
	callGraph := cgm cha.

	^ self extractFromCallGraph
]

{ #category : #extraction }
ServiceExtractor >> extractFromCallGraph [

	| cgMethods classes |
	classes := Dictionary new.
	cgMethods := Set with: methodToExtract.
	cgMethods addAll:
		(callGraph associations flatCollectAsSet: [ :a | a value ]).

	cgMethods do: [ :m |
		| class attributes |
		class := m parentType.
		attributes := self attributesUsedBy: m.
		classes
			at: class
			ifPresent: [ :entities | entities addAll: attributes ]
			ifAbsentPut: [ Set withAll: attributes ].
		(classes at: class) add: m.
		attributes do: [ :a |
			a incomingAccesses do: [ :access |
				(access isWrite and: [ access accessor name = '<Initializer>' ])
					ifTrue: [ (classes at: class) add: access accessor ] ] ] ].

	classes keysDo: [ :c |
		(c superclassHierarchy reject: #isStub) do: [ :sc |
			classes at: sc put: Set new ] ].


	classes keysDo: [ :c |
		c methods do: [ :m |
			m isConstructor ifTrue: [ (classes at: c) add: m ] ] ].

	classes valuesDo: [ :v |
		v do: [ :e |
			((e isAttribute or: [ e isMethod ]) and: [
				 e declaredType isClass and: [ e declaredType isStub not ] ])
				ifTrue: [ classes at: e declaredType ifAbsentPut: [ Set new ] ] ] ].

	^ classes
]

{ #category : #accessing }
ServiceExtractor >> methodToExtract [

	^ methodToExtract
]

{ #category : #accessing }
ServiceExtractor >> methodToExtract: anObject [

	methodToExtract := anObject
]
