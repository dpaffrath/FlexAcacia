/*
* Copyright 2009 François de Campredon
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package com.deCampredon.flexAcacia.validation.core
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;

	/**
	 *  Dispatched when validation succeeds.
	 *
	 *  @eventType mx.events.ValidationResultEvent.VALID 
	 *  
	 */
	[Event(name="valid", type="mx.events.ValidationResultEvent")]
	
	/** 
	 *  Dispatched when validation fails.
	 *
	 *  @eventType mx.events.ValidationResultEvent.INVALID 
	 *  
	 */
	[Event(name="invalid", type="mx.events.ValidationResultEvent")]
	
	/**
	 * Responsible for validating an object using a set of given <code>Constraint</code>.
	 *  
	 * @author François de Campredon
	 */
	public class ValidationSession extends EventDispatcher
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * @param target session validation target 
		 * @param constraints set of <code>Constraint</code> used by this session
		 */
		public function ValidationSession(target:Object,constraints:Array)
		{
			super();
			this.constraints = constraints;
			this.target = target;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  constraints
		//----------------------------------
		/**
		 * set of <code>Constraint</code> used by this session
		 */
		protected var constraints:Array
		
		//----------------------------------
		//  target
		//----------------------------------
		/**
		 * session validation target 
		 */
		protected var target:Object;
		
		
		
		//----------------------------------
		//  resultEvent
		//----------------------------------
		/**
		 * @private
		 */
		private var _resultEvent:ValidationResultEvent;
		
		
		/**
		 * the <code>ValidationResultEvent</code> generated by this session
		 */
		public function get resultEvent():ValidationResultEvent {
			return _resultEvent;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var numberConstraint:int;
		
		/**
		 * @private
		 */
		private var _results:Array;
		
		
		/**
		 * start the validation process
		 */
		public function startValidation():void {
			
			numberConstraint = 0;
			_results = [];
			numberConstraint =constraints.length;
			if(numberConstraint == 0) {
				dispatchEvent(new ValidationResultEvent(ValidationResultEvent.VALID,false,false));
			}
			for each(var constraint:Constraint in constraints) {
				constraint.addEventListener(ValidationResultEvent.VALID,validationResultHandler);
				constraint.addEventListener(ValidationResultEvent.INVALID,validationResultHandler);
				constraint.validate(target);
				
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handling
		//
		//--------------------------------------------------------------------------
		
		/**
		 * handle ValidationResultEvent dispatched by constraints of this session 
		 */
		protected function validationResultHandler(event:ValidationResultEvent):void {
			IEventDispatcher(event.currentTarget).removeEventListener(ValidationResultEvent.VALID,validationResultHandler);
			IEventDispatcher(event.currentTarget).removeEventListener(ValidationResultEvent.INVALID,validationResultHandler);
			if(event.type == ValidationResultEvent.INVALID) {
				_results = _results.concat(event.results);
			}
			numberConstraint--;
			if(numberConstraint == 0) {
				if(_results && _results.length == 0) {
					_resultEvent = new ValidationResultEvent(ValidationResultEvent.VALID,false,false);
				}
				else {
					_resultEvent = new ValidationResultEvent(ValidationResultEvent.INVALID,false,false,null,_results);
				}
				dispatchEvent(_resultEvent);
			}
		}
	}
}