Class {
	#name : 'MiServiceExtractorBrowser',
	#superclass : 'MiAbstractBrowser',
	#instVars : [
		'methodList',
		'functionalityMethods',
		'canvas',
		'submitButton'
	],
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'instance creation' }
MiServiceExtractorBrowser class >> newModel [

	^ MiServiceExtractorModel new
]

{ #category : 'instance creation' }
MiServiceExtractorBrowser class >> open [

	<script>
	^ super open
]

{ #category : 'specs' }
MiServiceExtractorBrowser class >> title [

	^ 'Service Extractor'
]

{ #category : 'specs' }
MiServiceExtractorBrowser class >> windowSize [

	^ self currentWorld extent
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> buildMap [

	MiServiceExtractorBuilder new
		           mapModel: self model;
		           container: canvas canvas;
		           build
]

{ #category : 'testing' }
MiServiceExtractorBrowser >> canFollowEntity: anObject [

	^ anObject asMooseGroup allSatisfy: [ :m | m isMethod ]
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> connectPresenters [

	submitButton action: [ 
		
		self run.
		self model featureWithCommonMethods ]
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> followEntity: anEntity [

	| list |
	list := anEntity asOrderedCollection.
	methodList items: list.
	specModel methodList: list
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> initializePresenters [

	| sep |
	methodList := (self instantiate: SpFilteringSelectableListPresenter)
		              display: [ :i | i parentType name , '>>' , i name ].
	submitButton := self newButton label: 'Submit'.
	canvas := self newRoassal.
	canvas canvas @ RSCanvasController.

	sep := self newRoassal.

	sep canvas color: (Color fromHexString: 'BBBBBB').

	self layout: (SpBoxLayout newLeftToRight
			 add: (SpBoxLayout newTopToBottom
					  add: methodList;
					  add: submitButton expand: false;
					  yourself)
			 width: 300;
			 add: sep width: 1;
			 add: canvas;
			 yourself)
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> miSelectedItem [

	^ {  }
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> resetCanvas [

	canvas canvas shapes do: #remove
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> run [

	1halt.
	methodList items ifEmpty: [ ^self ].
	self model methodToExtract: methodList selectedItems first.
	self resetCanvas.
	self buildMap
]
