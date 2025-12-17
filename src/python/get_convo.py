import psycopg2
import pandas as pd
import dotenv
import os

dotenv.load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

def load_conversation(user_id):
    conn = psycopg2.connect(DATABASE_URL, sslmode='require')
    df = pd.read_sql_query(f"SELECT * FROM conversation_logs WHERE user_id = '{user_id}' ORDER BY timestamp ASC", con=conn)
    conn.close()
    df = df.melt(id_vars=['user_id', 'timestamp'], value_vars=['message', 'response'], var_name='role', value_name='content').sort_values(by=['timestamp', 'role'])
    # duplicate the first row so that the first message is from the assistant
    df = pd.concat([df.iloc[0:1], df]).reset_index(drop=True)
    df['role'][1] = 'message'
    df['content'][1] = 'hi!'
    df['role'][0] = 'system'
    # replace message with user and response with assistant
    df['role'] = df['role'].replace({'message': 'user', 'response': 'system'})
    session_messages = list(test[['role', 'content']].to_dict().values())
    return session_messages

def load_conversation2(user_id):
    conn = psycopg2.connect(DATABASE_URL, sslmode='require')
    cur = conn.cursor()

    # Prepare the query for 'message'
    query_message = """
    SELECT 'user' as role, message as content, timestamp 
    FROM conversation_logs 
    WHERE user_id = %s and message is not null
    """

    # Execute the query for 'message'
    cur.execute(query_message, (user_id,))

    # Fetch all the rows for 'message'
    rows_message = cur.fetchall()

    # Prepare the query for 'response'
    query_response = """
    SELECT 'assistant' as role, response as content, timestamp 
    FROM conversation_logs 
    WHERE user_id = %s and response is not null
    """

    # Execute the query for 'response'
    cur.execute(query_response, (user_id,))

    # Fetch all the rows for 'response'
    rows_response = cur.fetchall()

    # Concatenate and sort the rows
    all_rows = sorted(rows_message + rows_response, key=lambda x: x[2])

    # Format the rows into the desired dictionary format
    session_messages = [{"role": row[0], "content": row[1]} for row in all_rows]

    cur.close()
    conn.close()
    return session_messages

# Example usage
# user_id comes from the ResponseId variable
load_conversation2(user_id="R_5K0GwqsoNxFDsdh")

