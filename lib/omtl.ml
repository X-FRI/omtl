(* Copyright (c) 2023 Muqiu Han
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright notice,
 *       this list of conditions and the following disclaimer in the documentation
 *       and/or other materials provided with the distribution.
 *     * Neither the name of omtl nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *)

include Types
include Utils
include Info
open Color

let test status (f : unit -> (unit, string) Result.t) : Test_Result.t =
  match status with
  | { backtrace; callstack; force = _; suit = _ } -> begin
      try
        let time (f : unit -> (unit, string) Result.t) : (float, string) Result.t =
          let timer : float = Standalone_unix.gettimeofday () in
          if backtrace then Printexc.record_backtrace true;
          let result = f () in
          if backtrace then Printexc.record_backtrace false;
          Result.map (fun () -> Standalone_unix.gettimeofday () -. timer) result
        in
        match time f with
        | Result.Ok time -> Test_Result.Ok time
        | Result.Error info ->
            let backtrace = if backtrace then Backtrace.get () else String.empty
            and callstack = if callstack then CallStack.get () else String.empty in
            Fail (info, backtrace, callstack)
      with
      | Failure s ->
          let backtrace = if backtrace then Backtrace.get () else String.empty
          and callstack = if callstack then CallStack.get () else String.empty in
          Fail (s, backtrace, callstack)
      | e -> Fail ("Exception: " ^ Printexc.to_string e, String.empty, String.empty)
    end


let test_case status (test_case : test_case) : string =
  match status with
  | { backtrace; callstack; force; suit = _ } -> (
      let name, f = test_case in
      match test status f with
      | Test_Result.Ok time ->
          Format.sprintf
            "\t %s- %s...%s %s"
            (text ~force ~color:Ok "o")
            name
            (text ~force ~color:Ok "OK")
            (text ~force ~color:Time (Format.sprintf "(%f ms)" (time *. 1000.)))
      | Test_Result.Fail (i, b, c) ->
          Format.sprintf
            "\t %s- %s...%s %s\n\t\t %s\n%s%s"
            (text ~force ~color:Fail "o")
            name
            (text ~force ~color:Fail "FAIL")
            (text ~force ~color:Time "(0 ms)")
            (text ~force ~color:Fail_info (Format.sprintf "|!| %s" i))
            (if backtrace then
               Format.sprintf
                 "\t\t %s %s\n"
                 (text ~force ~color:Info_title "BACKTRACE")
                 (if String.length b = 0 then "No more info" else b)
             else
               String.empty)
            (if callstack then
               Format.sprintf
                 "\t\t %s %s\n"
                 (text ~force ~color:Info_title "CALLSTACK")
                 (if String.length b = 0 then "No more info" else c)
             else
               String.empty))


let test_suit status : unit =
  match status with
  | { backtrace = _; callstack = _; force; suit } ->
      let name, test_case_list = suit in
      Format.sprintf
        "%s %s %s"
        (text ~force ~color:Dash "|-")
        (text ~force ~color:First_class_info "Test suit for")
        (text ~force ~color:Suit_name name)
      |> print_endline;
      List.iter (fun case -> test_case status case |> print_endline) test_case_list


let run
    ?(backtrace : bool = false)
    ?(callstack : bool = false)
    ?(force : bool = false)
    (suit : test_suit)
  =
  test_suit { backtrace; callstack; force; suit }
