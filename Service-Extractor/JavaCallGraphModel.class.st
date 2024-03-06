Class {
	#name : #JavaCallGraphModel,
	#superclass : #Object,
	#instVars : [
		'callGraph',
		'classes',
		'methods',
		'typeGraph',
		'entryMethod'
	],
	#category : #'Service-Extractor'
}

{ #category : #initialization }
JavaCallGraphModel >> addLinkFrom: m1 to: m2 [

	callGraph 
		at: m1
		ifPresent: [ :list | list add: m2 ]
		ifAbsentPut: [ Set with: m2 ]
]

{ #category : #accessing }
JavaCallGraphModel >> buildNodeFor: v [

	| label |
	label := String streamContents: [ :s |
		         | methodOrClass |
		         methodOrClass := v parentBehaviouralEntity.

		         methodOrClass isMethod ifTrue: [
			         s
				         nextPutAll: methodOrClass parentType name;
				         nextPut: $. ].
		         s
			         nextPutAll: methodOrClass name;
			         nextPut: $..
		         s nextPutAll: v name ].

	^ TypeGraphNode new
		  label: label;
		  famixEntity: v;
		  yourself
]

{ #category : #accessing }
JavaCallGraphModel >> buildtypeGraph [

	typeGraph := Dictionary new.
	methods do: [ :m |
		m parameters do: [ :p |
			p hasObjectType ifTrue: [
				typeGraph at: (self buildNodeFor: p) put: OrderedCollection new ] ].

		m localVariables do: [ :v |
			v hasObjectType ifTrue: [
				typeGraph at: (self buildNodeFor: v) put: OrderedCollection new ] ] ]
]

{ #category : #accessing }
JavaCallGraphModel >> callGraph [

	^ callGraph ifNil: [
		  | dict |
		  dict := Dictionary new.
		  dict at: entryMethod put: 0.
		  classes add: entryMethod parentType.
		  methods add: entryMethod.
		  self callGraph: dict depth: 0 method: entryMethod.
		  callGraph := dict ]
]

{ #category : #computing }
JavaCallGraphModel >> callGraph: dict depth: depth method: aMethod [

	| providers newDepth methodsToExplore |
	newDepth := depth + 1.
	providers := ((aMethod queryOutgoing: FamixTInvocation)
		              flatCollect: #allTargets) reject: #isStub.
	methodsToExplore := Set new.
	
	providers do: [ :m |
		methodsToExplore add: m.
		m parentType isParameterizedType ifFalse: [
			methodsToExplore addAll: m overridingMethods ] ].
	
	methodsToExplore do: [ :m |
		(dict includesKey: m) ifFalse: [
			dict at: m put: newDepth.
			classes add: m declaredType.
			methods add: m.
			self callGraph: dict depth: newDepth method: m] ].
	
	^ dict
]

{ #category : #initialization }
JavaCallGraphModel >> cha [

	| worklist |
	callGraph := Dictionary new.

	worklist := LinkedList new.

	worklist add: entryMethod.

	[ worklist isEmpty ] whileFalse: [
		| calls workMethod |
		workMethod := worklist removeLast.

		calls := workMethod queryOutgoing: FamixTInvocation.
		calls do: [ :call |
			| method overridingMethods |
			call candidates ifNotEmpty: 
			[method := call candidates first.

			method isStub ifFalse: [
				overridingMethods := OrderedCollection with: method.
				overridingMethods addAll: method overridingMethods.
				overridingMethods do: [ :oMeth |
					self addLinkFrom: workMethod to: oMeth.
					(callGraph includesKey: oMeth) ifFalse: [ worklist add: oMeth ] ] ]] ] ].
	^ callGraph
]

{ #category : #accessing }
JavaCallGraphModel >> entryMethod [

	^ entryMethod
]

{ #category : #accessing }
JavaCallGraphModel >> entryMethod: anObject [

	entryMethod := anObject
]

{ #category : #initialization }
JavaCallGraphModel >> initialize [

	classes := Set new.
	methods := Set new
]
