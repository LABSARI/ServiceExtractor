"
A service extrator. It takes a famix method and give all (available at static time) entities needed to execute that service.
"
Class {
	#name : 'ServiceExtractor',
	#superclass : 'Object',
	#instVars : [
		'methodToExtract',
		'callGraph',
		'classes'
	],
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'extraction' }
ServiceExtractor class >> extractMethod: aMethod [

	| slicedClasses |
	slicedClasses := self new
		                 extractMethod: aMethod;
		                 extractCHA;
		                 createModel
	"FAMIX2JavaVisitor new
		slicedClasses: slicedClasses;
		rootFolder:
			('/Users/slabsar/Documents/xpworkspace/exported/' , aMethod name)
				asFileReference;
		export: aMethod mooseModel"
]

{ #category : 'extraction' }
ServiceExtractor >> attributesUsedBy: aMethod [

	| dependencies attributes |
	dependencies := Set new.
	attributes := (aMethod accesses
		               collect: #variable
		               thenSelect: [ :var |
		               var isStub not and: [ var isAttribute ] ]) asSet.
	"attributes do: [ :att |
		dependencies add: att.
		att incomingAccesses do: [ :access |
			access isWrite ifTrue: [ dependencies add: access accessor ] ] ]."
	^ attributes
]

{ #category : 'extraction' }
ServiceExtractor >> collectDependenciesOf: aClass in: classDict [

	aClass ifNil: [ ^ self ].
	aClass isPrimitiveType ifTrue: [ ^ self ].
	"Before checking if the parametric class is stub, we need to look at parameters."
	aClass isParametricEntity ifTrue: [
		aClass concreteParameters do: [ :cp |
			self collectDependenciesOf: cp in: classDict ] ].

	"If it is stub we just import."
	aClass isStub ifTrue: [ ^ self ].
	classDict at: aClass ifPresent: [ ^ self ].
	classDict at: aClass ifAbsentPut: [ Set new ].

	"(aClass attributes collect: [ :a | a declaredType ]) do: [ :t |
		self collectDependenciesOf: t in: classDict ]."

	"(aClass methods collect: [ :m | m declaredType ]) do: [ :t |
		self collectDependenciesOf: t in: classDict ]."
	"(aClass methods flatCollect: [ :m |
		 m parameters , m localVariables collect: [ :p | p declaredType ] ])
		do: [ :t | self collectDependenciesOf: t in: classDict ]."

	"(aClass methods flatCollect: [ :m |
		 m outgoingReferences collect: [ :r | r referredType ] ]) do: [ :t |
		self collectDependenciesOf: t in: classDict ]"
]

{ #category : 'extraction' }
ServiceExtractor >> createModel [

	| subModel packages |
	self
		assert: classes notNil
		description:
		'classes should be computed before executing this method'.
	packages := Set new.
	subModel := FamixJavaModel named: methodToExtract name , 'Model'.

	classes associationsDo: [ :assoc |
		| type newType elements |
		type := assoc key.
		elements := assoc value.
		newType := type copy.
		subModel add: newType.
		packages addAll: (newType allAtScope: FamixJavaPackage).
		newType ].
	packages do: [ :p |
		| newPackage |
		newPackage := p copy.
		newPackage types:
			(newPackage types copy select: [ :t | classes includes: t ]).
		subModel add: newPackage ]
]

{ #category : 'extraction' }
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

{ #category : 'extraction' }
ServiceExtractor >> extract [

	^ self extractFromCallGraph
]

{ #category : 'extraction' }
ServiceExtractor >> extractCHA [

	^ self extractFromCallGraphCHA
]

{ #category : 'extraction' }
ServiceExtractor >> extractConfigurationFiles [

	
]

{ #category : 'extraction' }
ServiceExtractor >> extractFromCallGraph [

	| cgMethods classes cgm |
	cgm := JavaCallGraphModel new
		       entryMethod: self methodToExtract;
		       yourself.
	callGraph := self methodToExtract callGraph.

	classes := Dictionary new.
	cgMethods := Set with: methodToExtract.
	cgMethods addAll:
		(callGraph associations flatCollectAsSet: [ :a | a value ]).

	cgMethods do: [ :m |
		| class attributes localVariables |
		class := m parentType.
		localVariables := m localVariables asOrderedCollection
		                  , m parameters asOrderedCollection.
		attributes := self attributesUsedBy: m.
		localVariables , attributes asOrderedCollection do: [ :lv |
			| lvType |
			lvType := lv declaredType.
			(lvType notNil and: [ lvType isStub not ]) ifTrue: [
				classes at: lvType ifAbsentPut: [ Set new ] ].
			(lvType notNil and: [ lvType isParametricEntity ]) ifTrue: [
				lvType concreteParameters do: [ :cp |
					cp isStub ifFalse: [ classes at: cp ifAbsentPut: [ Set new ] ] ] ] ].


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
		(classes at: c) ifNotEmpty: [
			c methods do: [ :m |
				m isConstructor ifTrue: [ (classes at: c) add: m ] ] ] ].

	classes valuesDo: [ :v |
		v do: [ :e |
			((e isAttribute or: [ e isMethod ]) and: [
				 e declaredType isClass and: [ e declaredType isStub not ] ])
				ifTrue: [ classes at: e declaredType ifAbsentPut: [ Set new ] ] ] ].

	^ classes
]

{ #category : 'extraction' }
ServiceExtractor >> extractFromCallGraphCHA [

	| cgMethods cgm |
	cgm := JavaCallGraphModel new
		       entryMethod: self methodToExtract;
		       yourself.
	callGraph := cgm cha.

	classes := Dictionary new.
	cgMethods := Set with: methodToExtract.
	cgMethods addAll:
		(callGraph associations flatCollectAsSet: [ :a | a value ]).

	cgMethods do: [ :m |
		| class attributes localVariables |
		class := m parentType.
		localVariables := m localVariables asOrderedCollection
		                  , m parameters asOrderedCollection.
		attributes := self attributesUsedBy: m.
		localVariables , attributes asOrderedCollection do: [ :lv |
			| lvType |
			(lv isAttribute and: [ lv parentType ~= class ]) ifTrue: [
				classes
					at: lv parentType
					ifPresent: [ :entities | entities add: lv ]
					ifAbsentPut: [ Set with: lv ] ].
			lvType := lv declaredType.
			self collectDependenciesOf: lvType in: classes ].

		m overriddenMethod ifNotNil: [
			classes
				at: m overriddenMethod parentType
				ifPresent: [ :entities | entities add: m overriddenMethod ]
				ifAbsentPut: [ Set with: m overriddenMethod ] ].

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
		(classes at: c) ifNotEmpty: [
			c methods do: [ :m |
				m isConstructor ifTrue: [ (classes at: c) add: m ] ] ] ].


	classes valuesDo: [ :v |
		v do: [ :e |
			((e isAttribute or: [ e isMethod ]) and: [
				 e declaredType isClass and: [ e declaredType isStub not ] ])
				ifTrue: [ classes at: e declaredType ifAbsentPut: [ Set new ] ] ] ].

	classes keysDo: [ :c |
		(c superclassHierarchy reject: #isStub) do: [ :sc |
			classes at: sc put: Set new ] ].


	^ classes
]

{ #category : 'extraction' }
ServiceExtractor >> extractMethod: aMethod [

	self methodToExtract: aMethod.
	^ self extractCHA
]

{ #category : 'accessing' }
ServiceExtractor >> methodToExtract [

	^ methodToExtract
]

{ #category : 'accessing' }
ServiceExtractor >> methodToExtract: anObject [

	methodToExtract := anObject
]
